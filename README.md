# Story

This is aimed to be a simple text game engine where players
are presented with multiple choices to advance the game.
Whereas games like [Zork]() use some basic language parsing,
this skips that in the same way 
[Choose your own adventure](https://en.wikipedia.org/wiki/Choose_Your_Own_Adventure)
books gave multiple choices.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `story` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:story, "~> 0.1.0"}]
    end
    ```

  2. Ensure `story` is started before your application:

    ```elixir
    def application do
      [applications: [:story]]
    end
    ```

