defmodule Madness.Story do
  @moduledoc """
  Stories are a graph of areas, along with a pointer
  to the starting area.
  Stories are driven by choices given to a player,
  rather than natural language parsing which may be frustrating.
  """
  require Logger
  alias Madness.Story.Areas.Supervisor, as: SArea
  # Track a single story's data
  defmodule Data do
    @moduledoc """
    Struct wrapper for story data
    """
    defstruct initial: nil, title: "", id: nil
  end
  use GenServer

  @spec start_link(binary) :: pid
  def start_link(story) do
    Logger.debug "Starting a story #{story}"
    GenServer.start_link(__MODULE__, [story], name: via_tuple(story))
  end

  defp via_tuple(story) do
    {:via, :gproc, {:n, :l, {:madness, :story, story}}}
  end

  @spec whereis(binary) :: pid
  def whereis(story) do
    :gproc.whereis_name({:n, :l, {:madness, :story, story}})
  end

  @spec get_initial(pid) :: {:ok, binary}
  def get_initial(server) when is_pid(server) do
    GenServer.call(server, {:initial})
  end

  @spec add_area(pid) :: {:ok, binary}
  def add_area(server) when is_pid(server) do
    GenServer.call(server, {:add_area})
  end

  @spec set_initial(pid, binary) :: :ok
  def set_initial(server, area) when is_pid(server) do
    GenServer.call(server, {:set_initial, area})
  end

  @spec init([binary]) :: {:ok, Data}
  def init([story]) do
    # TODO load from disk
    {:ok, %Data{id: story}}
  end

  @spec handle_call(tuple, pid, Data) :: tuple
  def handle_call({:initial}, _from, state) do
    initial = state.initial
    case initial do
      nil -> {:reply, {:error, :no_initial_state}, state}
      init_val -> {:reply, {:ok, init_val}, state}
    end
  end

  def handle_call({:add_area}, _from, state) do
    story = state.id
    server = SArea.whereis(story)
    {:ok, area} = SArea.add_area(server, story)
    # TODO add to state
    {:reply, {:ok, area}, state}
  end

  def handle_call({:set_initial, area}, _from, state) do
    new_state = %{state | initial: area}
    {:reply, :ok, new_state}
  end
end
