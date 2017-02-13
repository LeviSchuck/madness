defmodule Madness.Player.Story do
  @moduledoc """
  Player Story keeps track of the state particular to player
  in a story.
  State is maintained even when the player's active story is not
  the story particular to this process.
  """
  require Logger
  alias Madness.Story, as: Story
  # Single story state for a single player
  defmodule Data do
    @moduledoc """
    Simple struct wrapper for player data
    """
    defstruct area: nil, vars: %{}, last_area: nil
  end
  use GenServer

  @spec start_link(binary, binary) :: pid
  def start_link(player, story) do
    name = via_tuple(player, story)
    GenServer.start_link(__MODULE__, [story], name: name)
  end

  defp via_tuple(player, story) do
    {:via, :gproc, {:n, :l, {:madness, :player_story, player, story}}}
  end

  @spec whereis(binary, binary) :: pid
  def whereis(player, story) do
    :gproc.whereis_name({:n, :l, {:madness, :player_story, player, story}})
  end

  @spec get_area(pid) :: binary
  def get_area(server) do
    GenServer.call(server, {:get_area})
  end

  @spec get_state(pid) :: %{}
  def get_state(server) do
    GenServer.call(server, {:get})
  end

  @type transition :: {:transition, binary}
  @type state1 :: {:state, atom, any}
  @type state2 :: {:state, atom, any, any}
  @type action :: transition | state1 | state2
  @spec exec(pid, action) :: :ok
  def exec(server, action) do
    GenServer.cast(server, {:exec, action})
  end

  @spec handle_cast(tuple, Data) :: tuple
  def handle_cast({:exec, action}, state) do
    new_state = exec_action(state, action)
    {:noreply, new_state}
  end

  @spec handle_call(tuple, pid, Data) :: tuple
  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_area}, _from, state) do
    area = state.area
    {:reply, area, state}
  end

  @spec init([binary]) :: {:ok, Data}
  def init([story]) do
    # TODO load area
    # Logger.debug "Init player story #{story}"
    server = Story.whereis(story)
    {:ok, area} = Story.get_initial(server)
    {:ok, %Data{area: area}}
  end

  @spec exec_action(%{}, action) :: %{}
  def exec_action(state, {:transition, area}) do
    last = state.area
    %{state | last_area: last, area: area}
  end

  def exec_action(state, {:state, op, var}) do
    old_vars = state.vars
    old_val = Map.get(old_vars, var)
    new_val = exec_new_val(op, old_val)
    new_vars = case new_val do
      nil -> Map.delete(old_vars, var)
      val -> Map.put(old_vars, var, val)
    end
    %{state | vars: new_vars}
  end

  def exec_action(state, {:state, op, var, val}) do
    old_vars = state.vars
    old_val = Map.get(old_vars, var)
    new_val = exec_new_val(op, old_val, val)
    new_vars = Map.put(old_vars, var, new_val)
    %{state | vars: new_vars}
  end

  def exec_action(state, act) do
    Logger.warn "Unknown action #{inspect act}"
    state
  end

  defp exec_new_val(:inc, nil), do: 1
  defp exec_new_val(:inc, x), do: x + 1
  defp exec_new_val(:dec, nil), do: 0
  defp exec_new_val(:dec, x), do: x - 1
  defp exec_new_val(:clear, _), do: nil

  defp exec_new_val(:insert, nil, val), do: MapSet.put(MapSet.new, val)
  defp exec_new_val(:insert, s, val), do: MapSet.put(s, val)
  defp exec_new_val(:remove, nil, _), do: nil
  defp exec_new_val(:remove, s, val), do: MapSet.delete(s, val)
  defp exec_new_val(:set, _, val), do: val

end
