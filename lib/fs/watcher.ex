defmodule BigBrother.FS.Watcher do
  @moduledoc false
  use GenServer

  @recompile_events [
    [:renamed],
    [:removed],
    [:modified],
    [:modified, :closed]
  ]

  @default_debounce 1000

  @default_patterns [
    ~r"lib/.*(ex)$"
  ]

  defp app_config(), do: Application.get_env(:big_brother_ex, :reload_config) || []

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    config = load_configuration()

    table_ref = create_ets_table()
    start_fs_watcher()
    reloader_pid = start_reloader(config)

    send(self(), :send_changes)

    {:ok,
     Map.merge(
       config,
       %{table_ref: table_ref, reloader_pid: reloader_pid, debounce: 1000}
     )}
  end

  defp load_configuration() do
    debounce = Keyword.get(app_config(), :debounce, @default_debounce)

    reloader =
      Keyword.get(app_config(), :reloader) ||
        raise """
          Reloader module not defined. Ensure you have the reloader module defined in your configuration file:

          config :big_brother, :reload_config,
            reloader: BigBrother.FS.Reloader
        """

    reloader_opts = Keyword.get(app_config(), :reloader_opts)
    patterns = Keyword.get(app_config(), :patterns, @default_patterns)

    %{debounce: debounce, reloader: reloader, reloader_opts: reloader_opts, patterns: patterns}
  end

  defp start_fs_watcher() do
    # Watch all files from this root
    :fs.start_link(:fs_watcher, File.cwd!())
    :fs.subscribe(:fs_watcher)
  end

  defp create_ets_table() do
    :ets.new(:modified_files, [:set, :private])
  end

  defp start_reloader(config) do
    reloader_module = config.reloader
    opts = config.reloader_opts
    {:ok, reloader_pid} = GenServer.start_link(reloader_module, opts)
    reloader_pid
  end

  def handle_info(:send_changes, config) do
    modified_files = :ets.tab2list(config.table_ref)
    :ets.delete_all_objects(config.table_ref)

    send(config.reloader_pid, {:files_changed, modified_files})
    Process.send_after(self(), :send_changes, config.debounce)
    {:noreply, config}
  end

  def handle_info({_pid, {:fs, :file_event}, {path_charlist, event}}, config)
      when event in @recompile_events do
    path = List.to_string(path_charlist)
    relative_path = Path.relative_to(path, project_root_path())

    Enum.reduce_while(config.patterns, 0, fn pattern, _acc ->
      if Regex.match?(pattern, relative_path) do
        time_now = DateTime.utc_now()
        :ets.insert(config.table_ref, {time_now, {path, event}})
        {:halt, 0}
      else
        {:cont, 0}
      end
    end)

    {:noreply, config}
  end

  def handle_info(_message, config) do
    {:noreply, config}
  end

  # Workaround for umbrella projects
  defp project_root_path() do
    Path.expand(Mix.Project.deps_path() <> "/../")
  end
end
