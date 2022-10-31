defmodule BigBrother.FS.Reloader do
  @moduledoc """
    Genserver responsible for triggering recompilation and reload of modules.
  """
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle_info({:files_changed, []}, state) do
    {:noreply, state}
  end

  def handle_info({:files_changed, _files}, state) do
    BigBrother.CodeReloader.Server.reload!()
    {:noreply, state}
  end
end
