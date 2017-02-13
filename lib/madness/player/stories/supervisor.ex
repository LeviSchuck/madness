defmodule Madness.Player.Stories.Supervisor do
  @moduledoc """
  Supervises all player story data instances.
  Story data instances may be added via `add_story`.
  """
  require Logger
  # Track all players
  use Supervisor

  @spec start_link(binary) :: pid
  def start_link(player) do
    Supervisor.start_link(__MODULE__, [player], name: via_tuple(player))
  end

  defp via_tuple(player) do
    {:via, :gproc, {:n, :l, {:madness, :player_stories, player}}}
  end

  @spec whereis(binary) :: pid | nil
  def whereis(player) do
    :gproc.whereis_name({:n, :l, {:madness, :player_stories, player}})
  end

  @spec init([binary]) :: {:ok, tuple}
  def init([_player]) do
    # Logger.debug "Player stories #{player}"
    children = [
      worker(Madness.Player.Story, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @spec add_story(pid, binary, binary) :: {:ok, pid}
  def add_story(supervisor, player, story) when is_pid(supervisor) do
    # TODO: get player state
    {:ok, pid} = Supervisor.start_child(supervisor, [player, story])
    {:ok, pid}
  end
end
