# BigBrother

Elixir library capable of watching and recompiling/reloading files at runtime. This is an alternative to [Phoenix.CodeReloader](https://hexdocs.pm/phoenix/Phoenix.CodeReloader.html) for projects that don't use phoenix as their application.

# Installation

Add :big_brother to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:big_brother_ex, "~> 0.1", only: [:dev]}
  ]
end
```

# Configuration

You can configure the dependency by adding to `config/dev.exs` :

```elixir
config :big_brother_ex, :reload_config,
  reloader: BigBrother.FS.Reloader,
  debounce: 1000,
  patterns: [
    ~r"lib/.*(ex)$"
  ]
```
Where the options are:
- **reloader** - module responsible for reloading the code, can be customized by a custom module.
- **debounce** - debounce time for reloading code in milliseconds, by default it is set to `1000ms`.
- **patterns** - a list of regex patterns that will trigger recompilation. **Important:** the FS watcher is configured to look from the root of the project recursively, this means that you cannot trigger recompilation on files that are not part of the project. By default `~r"lib/.*(ex)$"` pattern is used on no configuration.

# Starting the reloader

If your application was generated with a supervisor (by passing `--sup` to mix new) you will have a `lib/my_app/application.ex` file containing the application start callback that defines and starts your supervisor. You just need to edit the `start/2` function to start the server as a supervisor on your application's supervisor:

```elixir
def start(_type, _args) do
  children = [
    BigBrother.ReloadServer,
  ]

  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

# Dependencies

1. Big Brother first of all depends on [Mix](https://hexdocs.pm/mix/1.14/Mix.html) for both recompilation and relative paths, **the library will not work without mix**.

2. Native binaries for [FS](https://github.com/synrc/fs) library watch events : 


> * Mac [fsevent](https://github.com/thibaudgg/rb-fsevent)
> * Linux [inotify](https://github.com/rvoicilas/inotify-tools/wiki)
> * Windows [inotify-win](https://github.com/thekid/inotify-win)

# Umbrella projects

The library supports umbrella projects. All that is required to make it work is to **add the dependency and configuration to one of the projects**.

# TODO
- [ ] Implement possibility to restart applications based on a configuration.
- [ ] Write tests.
- [ ] Implement possibility for deps recompilation when a dependency by path is specified.
- [ ] Create a generator for easier intergration on new projects.
- [ ] Investigate integrations with more advanced systems such as phoenix template compiler/generator.
