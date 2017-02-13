defmodule Madness.Story.Supervisor do
  @moduledoc """
  Story supervisor, hosts the story and areas supervisor
  """
  require Logger
  # Track a single story's data
  use Supervisor

  @spec start_link(binary) :: pid
  def start_link(story) do
    Supervisor.start_link(__MODULE__, [story])
  end

  @spec init([binary]) :: {:ok, tuple}
  def init([story]) do
    # Logger.debug "Story supervise #{story}"
    children = [
      supervisor(Madness.Story.Areas.Supervisor, [story]),
      worker(Madness.Story, [story])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
