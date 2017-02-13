defmodule Madness.Supervisor do
  @moduledoc """
  Madness application supervisor
  """
  require Logger
  # All Stories and Players
  use Supervisor
  @spec start_link :: pid
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  @spec init([]) :: {:ok, tuple}
  def init([]) do
    Logger.debug "Supervising The Madness"
    children = [
      supervisor(Madness.Stories.Supervisor, []),
      supervisor(Madness.Players.Supervisor, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
