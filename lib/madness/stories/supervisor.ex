defmodule Madness.Stories.Supervisor do
  @moduledoc """
  Madness supervisor of all stories, add stories via `add_story`
  """
  require Logger
  # This is where we keep track of stories
  use Supervisor

  @spec start_link :: pid
  def start_link do
    name = {:via, :gproc, {:n, :l, {:madness, :stories}}}
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  @spec whereis :: pid
  def whereis do
    :gproc.whereis_name({:n, :l, {:madness, :stories}})
  end

  @spec init([]) :: tuple
  def init([]) do
    # Logger.debug "Madness Stories initiate"
    children = [
      supervisor(Madness.Story.Supervisor, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @spec add_story(pid) :: {:ok, binary}
  def add_story(supervisor) when is_pid(supervisor) do
    story = UUID.uuid4
    Logger.debug "Adding a story - #{story}"
    Supervisor.start_child(supervisor, [story])
    {:ok, story}
  end
end
