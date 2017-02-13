defmodule Madness.Story.Area do
  @moduledoc """
  Areas represent a localized unit of a story.
  Areas may describe what the scene is via `list_says`.
  Areas also may transition to other areas or change state,
  these are described via `list_steps` which has a key and title.
  Steps and Says may be conditional on player state.
  Conditions may also be aggregate of other conditions such as
  OR logic or AND logic.

  """
  require Logger
  # Each area and it's things
  defmodule Data do
    @moduledoc """
    Namespace for data used in an area
    """
    defmodule Area do
      @moduledoc """
      Central data structure for an area
      """
      defstruct conditions: %{}, steps: %{}, tell: [], id: nil, story: nil
    end
    defmodule Condition do
      @moduledoc """
      Conditions data structure used in says and steps.
      Conditions often compare player state and may be
      aggregates of other state in OR or AND logic.
      """
      defstruct id: nil, type: nil, params: []
    end
    defmodule Say do
      @moduledoc """
      Say is used to generate the scene description and may
      be conditional on player state.
      """
      defstruct condition: true, type: :plain, param: ""
    end
    defmodule Step do
      @moduledoc """
      A step often transitions between areas using commands.
      Steps may also change player state by commands.
      """
      defstruct condition: true, title: "", commands: []
    end
    defmodule Command do
      @moduledoc """
      Commands change player state and are executed as steps are selected.
      """
      defstruct type: nil, var: nil, op: nil, param: nil
    end
  end
  use GenServer

  @spec start_link(binary, binary) :: pid
  def start_link(story, area) do
    # Logger.debug "Story area start #{story} - #{area}"
    GenServer.start_link(__MODULE__, [story, area], name: via_tuple(area))
  end

  defp via_tuple(area) do
    {:via, :gproc, {:n, :l, {:madness, :area, area}}}
  end

  @spec whereis(any) :: pid
  def whereis(area) do
    :gproc.whereis_name({:n, :l, {:madness, :area, area}})
  end

  @spec init([binary]) :: {:ok, Data.Area}
  def init([story, area]) do
    # TODO load from disk
    state = %Data.Area{id: area, story: story}
    {:ok, state}
  end

  @spec add_condition(pid, binary, atom, any) :: :ok
  def add_condition(server, name, type, params) do
    GenServer.call(server, {:add_condition, name, type, params})
  end

  @spec remove_condition(pid, binary) :: :ok
  def remove_condition(server, name) do
    # TODO implement
    GenServer.call(server, {:remove_condition, name})
  end

  @spec list_all_conditions(pid) :: {:ok, [tuple]}
  def list_all_conditions(server) do
    # TODO implement
    GenServer.call(server, {:list, :all_conditions})
  end

  @spec add_say(pid, atom, binary) :: :ok
  def add_say(server, type, text) do
    GenServer.call(server, {:add_say, true, type, text})
  end

  @spec add_say(pid, any, atom, binary) :: :ok
  def add_say(server, condition, type, text) do
    GenServer.call(server, {:add_say, condition, type, text})
  end

  @spec add_say(pid, any, atom, binary, integer) :: :ok
  def add_say(server, condition, type, text, after_say) do
    GenServer.call(server, {:add_say, condition, type, text, after_say})
  end

  @spec update_say_text(pid, integer, binary) :: :ok
  def update_say_text(server, at, text) do
    # TODO implement
    GenServer.call(server, {:update_say_text, at, text})
  end

  @spec update_say_condition(pid, integer, any) :: :ok
  def update_say_condition(server, at, condition) do
    # TODO implement
    GenServer.call(server, {:update_say_condition, at, condition})
  end

  @spec remove_say(pid, integer) :: :ok
  def remove_say(server, at) do
    # TODO implement
    GenServer.call(server, {:remove_say, at})
  end

  @spec add_step(pid, binary, binary) :: :ok
  def add_step(server, step, title) do
    GenServer.call(server, {:add_step, step, true, title})
  end

  @spec add_step(pid, any, binary, binary) :: :ok
  def add_step(server, condition, step, title) do
    GenServer.call(server, {:add_step, step, condition, title})
  end

  @spec remove_step(pid, binary) :: :ok
  def remove_step(server, step) do
    # TODO implement
    GenServer.call(server, {:remove_step, step})
  end

  @spec update_step_title(pid, binary, binary) :: :ok
  def update_step_title(server, step, title) do
    # TODO implement
    GenServer.call(server, {:update_step_title, step, title})
  end

  @spec update_step_condition(pid, binary, any) :: :ok
  def update_step_condition(server, step, condition) do
    # TODO implement
    GenServer.call(server, {:update_step_condition, step, condition})
  end

  @spec add_transition_command(pid, binary, binary) :: :ok
  def add_transition_command(server, step, area) do
    GenServer.call(server, {:add_command, step, :transition, nil, nil, area})
  end

  @spec add_state_command_inc(pid, binary, any) :: :ok
  def add_state_command_inc(server, step, var) do
    GenServer.call(server, {:add_command, step, :state, var, :inc, nil})
  end

  @spec add_state_command_dec(pid, binary, any) :: :ok
  def add_state_command_dec(server, step, var) do
    GenServer.call(server, {:add_command, step, :state, var, :dec, nil})
  end

  @spec add_state_command_set(pid, binary, any, any) :: :ok
  def add_state_command_set(server, step, var, val) do
    GenServer.call(server, {:add_command, step, :state, var, :set, val})
  end

  @spec add_state_command_clear(pid, binary, any) :: :ok
  def add_state_command_clear(server, step, var) do
    GenServer.call(server, {:add_command, step, :state, var, :clear, nil})
  end

  @spec add_state_command_insert(pid, binary, any, any) :: :ok
  def add_state_command_insert(server, step, var, val) do
    GenServer.call(server, {:add_command, step, :state, var, :insert, val})
  end

  @spec add_state_command_remove(pid, binary, any, any) :: :ok
  def add_state_command_remove(server, step, var, val) do
    GenServer.call(server, {:add_command, step, :state, var, :remove, val})
  end

  @spec remove_step_command(pid, binary, integer) :: :ok
  def remove_step_command(server, step, at) do
    # TODO implement
    GenServer.call(server, {:remove_command, step, at})
  end

  @type step :: {binary, binary}
  @spec list_all_steps(pid) :: [step]
  def list_all_steps(server) do
    # TODO implement
    GenServer.call(server, {:list, :all_steps})
  end

  @spec list_steps(pid, %{}) :: [step]
  def list_steps(server, state) do
    GenServer.call(server, {:list, :some_steps, state})
  end

  @type transition_com :: {:transition, any}
  @type state_com :: {:state, atom, any} | {:state, atom, any, any}
  @type external_command :: transition_com | state_com
  @spec list_step_commands(pid, any) :: [external_command]
  def list_step_commands(server, step) do
    GenServer.call(server, {:list, :step_commands, step})
  end

  @type say :: {atom, any}
  @spec list_all_says(pid) :: [say]
  def list_all_says(server) do
    # TODO implement
    GenServer.call(server, {:list, :all_says})
  end

  @spec list_says(pid, %{}) :: [say]
  def list_says(server, state) do
    GenServer.call(server, {:list, :some_says, state})
  end

  # --------------------------------------------------------------------

  @spec handle_call(tuple, pid, Data) :: tuple
  def handle_call({:add_condition, name, type, params}, _from, state) do
    # Logger.debug "Adding condition #{inspect {name, type, params}}"
    new_conditions = Map.put(state.conditions, name, {type, params})
    nstate = %{state | conditions: new_conditions}
    {:reply, :ok, nstate}
  end

  def handle_call({:add_say, condition, type, text}, _from, state) do
    data = %Data.Say{condition: condition, type: type, param: text}
    nstate = %{state | tell: state.tell ++ [data]}
    {:reply, :ok, nstate}
  end

  def handle_call({:add_say, condition, type, text, -1}, _from, state) do
    data = %Data.Say{condition: condition, type: type, param: text}
    nstate = %{state | tell: [data | state.tell]}
    {:reply, :ok, nstate}
  end

  def handle_call({:add_say, condition, type, text, pos}, _from, state) do
    data = %Data.Say{condition: condition, type: type, param: text}
    nstate = %{state | tell: List.insert_at(state.tell, pos, data)}
    {:reply, :ok, nstate}
  end

  def handle_call({:add_step, step, condition, title}, _from, state) do
    data = %Data.Step{condition: condition, title: title}
    nstate = %{state | steps: Map.put(state.steps, step, data)}
    {:reply, :ok, nstate}
  end

  def handle_call({:add_command, step, type, var, op, param}, _from, state) do
    {stat, nsteps} = Map.get_and_update!(state.steps, step, fn (step_data) ->
      ncom = %Data.Command{type: type, var: var, op: op, param: param}
      ndata = %{step_data | commands: [ncom | step_data.commands]}
      {step_data, ndata}
    end)

    case stat do
      nil -> {:reply, :error, state}
      _ -> {:reply, :ok, %{state | steps: nsteps}}
    end
  end

  def handle_call({:list, :some_says, pstate}, _from, state) do
    say = state.tell
      |> Enum.filter(fn (data) ->
        eval_condition(data.condition, state, pstate)
      end)
      |> Enum.map(fn (data) ->
        {data.type, data.param}
      end)
    {:reply, {:ok, say}, state}
  end

  def handle_call({:list, :some_steps, pstate}, _from, state) do
    steps = state.steps
      |> Enum.filter(fn ({_, data}) ->
        eval_condition(data.condition, state, pstate)
      end)
      |> Enum.map(fn ({name, data}) ->
        {name, data.title}
      end)
    {:reply, {:ok, steps}, state}
  end

  def handle_call({:list, :step_commands, step}, _from, state) do
    comm_internal = case Map.get(state.steps, step) do
      nil -> []
      res -> res.commands
    end
    comms = Enum.map(comm_internal, &eval_command/1)
    {:reply, {:ok, comms}, state}
  end

  # --------------------------------------------------------------------

  defp eval_condition(condition, state, pstate) do
    res = case condition do
      true -> true
      nil -> false
      c ->
        rule = Map.get(state.conditions, c)
        eval_rule(rule, pstate)
    end
    # Logger.debug "Condition: #{inspect {condition, res, state.conditions, vars}}"
    res
  end

  defp eval_rule({:eq, {name, val}}, vars) do
    case Map.get(vars, name) do
      nil -> false
      player_val -> player_val == val
    end
  end

  defp eval_rule({:neq, {name, val}}, vars) do
    case Map.get(vars, name) do
      nil -> true
      player_val -> player_val != val
    end
  end

  defp eval_command(com) do
    case com.type do
      :transition -> {:transition, com.param}
      :state -> eval_command_state(com)
    end
  end

  defp eval_command_state(com) do
    with_param = case com.op do
      :insert -> true
      :remove -> true
      :set -> true
      _ -> false
    end
    if with_param do
      {:state, com.op, com.var, com.param}
    else
      {:state, com.op, com.var}
    end
  end
end
