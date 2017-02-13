defmodule Madness.Player do
  @moduledoc """
  Players may participate in many stories but only
  one story is active at a time.
  Each Player process is to be coupled with an external
  communication process.
  """
  require Logger
  alias Madness.Player.Story, as: PStory
  alias Madness.Story.Area, as: SArea
  alias Madness.Player.Stories.Supervisor, as: PSSupervisor
  # Single player
  defmodule Data do
    @moduledoc """
    Simple struct wrapper for a player
    """
    defstruct active_story: nil, id: nil
  end
  use GenServer

  @spec start_link(binary) :: pid
  def start_link(player) do
    Logger.debug "Starting player #{player}"
    GenServer.start_link(__MODULE__, [player], name: via_tuple(player))
  end

  defp via_tuple(player) do
    {:via, :gproc, {:n, :l, {:madness, :player, player}}}
  end

  @spec whereis(binary) :: pid
  def whereis(player) do
    :gproc.whereis_name({:n, :l, {:madness, :player, player}})
  end

  @spec add_story(pid, binary) :: :ok
  def add_story(server, story) when is_pid(server) do
    GenServer.call(server, {:add_story, story})
  end

  @spec set_story(pid, binary) :: :ok
  def set_story(server, story) when is_pid(server) do
    GenServer.call(server, {:set_active, story})
  end

  @spec get_story(pid) :: binary
  def get_story(server) when is_pid(server) do
    {:ok, story} = GenServer.call(server, {:get_story})
    story
  end

  @spec say_story(pid) :: [tuple]
  def say_story(server) when is_pid(server) do
    {:ok, says} = GenServer.call(server, {:get_say})
    says
  end

  @spec get_choices(pid) :: [{binary, binary}]
  def get_choices(server) when is_pid(server) do
    {:ok, choices} = GenServer.call(server, {:get_steps})
    choices
  end

  @spec make_choice(pid, binary) :: :ok
  def make_choice(server, step) when is_pid(server) do
    GenServer.call(server, {:take_step, step})
  end

  @spec init([binary]) :: {:ok, Data}
  def init([player]) do
    {:ok, %Data{id: player}}
  end

  @spec handle_call(tuple, pid, Data) :: tuple
  def handle_call({:add_story, story}, _from, state) do
    player = state.id
    Logger.debug "Adding story #{story} to player #{player}"
    server = PSSupervisor.whereis(player)
    {:ok, _} = PSSupervisor.add_story(server, player, story)
    # TODO add to stories added to user
    {:reply, :ok, state}
  end

  def handle_call({:set_active, story}, _from, state) do
    newstate = %Data{state | active_story: story}
    {:reply, :ok, newstate}
  end

  def handle_call({:get_story}, _from, state) do
    story = state.active_story
    {:reply, {:ok, story}, state}
  end

  def handle_call({:get_say}, _from, state) do
    story = state.active_story
    player = state.id
    player_story_state_pid = PStory.whereis(player,story)
    player_story_state = PStory.get_state(player_story_state_pid)
    area = player_story_state.area
    area_pid = SArea.whereis area
    {:ok, says} = SArea.list_says(area_pid, player_story_state.vars)
    {:reply, {:ok, says}, state}
  end

  def handle_call({:get_steps}, _from, state) do
    # Logger.debug "Getting steps"
    story = state.active_story
    player = state.id
    player_story_state_pid = PStory.whereis(player, story)
    player_story_state = PStory.get_state(player_story_state_pid)
    area = player_story_state.area
    area_pid = SArea.whereis(area)
    {:ok, steps} = SArea.list_steps(area_pid, player_story_state.vars)
    {:reply, {:ok, steps}, state}
  end

  def handle_call({:take_step, step}, _from, state) do
    # Logger.debug "Taking step #{step}"
    story = state.active_story
    player = state.id
    player_story_state_pid = PStory.whereis(player,story)
    player_story_state = PStory.get_state(player_story_state_pid)
    area = player_story_state.area
    area_pid = SArea.whereis(area)
    {:ok, commands} = SArea.list_step_commands(area_pid, step)
    :ok = Enum.each(commands, &PStory.exec(player_story_state_pid, &1))
    {:reply, :ok, state}
  end
end
