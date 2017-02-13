defmodule Madness.Players.Supervisor do
  @moduledoc """
  Supervisor for all player, add player via `add_player`
  """
  require Logger
  # Track all players
  use Supervisor

  @spec start_link :: pid
  def start_link do
    name = {:via, :gproc, {:n, :l, {:madness, :players}}}
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  @spec whereis :: pid
  def whereis do
    :gproc.whereis_name({:n, :l, {:madness, :players}})
  end

  @spec init([]) :: tuple
  def init([]) do
    # Logger.debug "Players supervision start"
    children = [
      supervisor(Madness.Player.Supervisor, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @spec add_player(pid) :: {:ok, binary}
  def add_player(supervisor) when is_pid(supervisor) do
    player = UUID.uuid4
    Supervisor.start_child(supervisor, [player])
    {:ok, player}
  end
end
