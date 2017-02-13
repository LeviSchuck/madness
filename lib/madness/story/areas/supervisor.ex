defmodule Madness.Story.Areas.Supervisor do
  @moduledoc """
  Story area supervisor, areas may be added via `add_area`.
  """
  require Logger
  # Each area and it's things
  use Supervisor

  @spec start_link(binary) :: pid
  def start_link(story) do
    Supervisor.start_link(__MODULE__, [story], name: via_tuple(story))
  end

  defp via_tuple(story) do
    {:via, :gproc, {:n, :l, {:madness, :story_areas, story}}}
  end

  @spec whereis(binary) :: pid
  def whereis(story) do
    :gproc.whereis_name({:n, :l, {:madness, :story_areas, story}})
  end

  @spec init([binary]) :: tuple
  def init([_story]) do
    # Logger.debug "Story Areas #{story}"
    children = [
      worker(Madness.Story.Area, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @spec add_area(pid, binary) :: {:ok, binary}
  def add_area(supervisor, story) when is_pid(supervisor) do
    area = UUID.uuid4
    Logger.debug "Adding area #{area} to #{story}"
    Supervisor.start_child(supervisor, [story, area])
    {:ok, area}
  end
end
