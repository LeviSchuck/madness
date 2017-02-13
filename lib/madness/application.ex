defmodule Madness.Application do
  @moduledoc """
  Madness is the namespace for a basic text story engine.
  Stories consist of areas which each may describe the scene
  and provide multiple-choice like options to the player.
  """
  require Logger
  use Application

  @spec start(any, any) :: pid
  def start(_type, _args) do
    Logger.debug "Starting The Maddness"
    Madness.Supervisor.start_link()
  end
end
