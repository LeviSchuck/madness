defmodule Madness.Player.Supervisor do
  @moduledoc """
  Supervisor for a single player, hosts the player and
  the supervisor for player story data instances.
  """
  require Logger
  # Single player and story states
  use Supervisor

  @spec start_link(binary) :: pid
  def start_link(player) do
    # Logger.debug "Player supervisor #{player}"
    Supervisor.start_link(__MODULE__, [player])
  end

  @spec init([binary]) :: {:ok, tuple}
  def init([player]) do
    children = [
      worker(Madness.Player, [player], restart: :permanent),
      supervisor(Madness.Player.Stories.Supervisor, [player])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
