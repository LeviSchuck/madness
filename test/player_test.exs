defmodule PlayerTest do
  use ExUnit.Case
  doctest Madness.Player

  test "Steps" do
    story_sup_pid = Madness.Stories.Supervisor.whereis
    {:ok, story_uuid} = Madness.Stories.Supervisor.add_story story_sup_pid
    story_pid = Madness.Story.whereis story_uuid

    {:ok, area1_uuid} = Madness.Story.add_area story_pid
    {:ok, area2_uuid} = Madness.Story.add_area story_pid
    :ok = Madness.Story.set_initial(story_pid, area1_uuid)
    area1_pid = Madness.Story.Area.whereis area1_uuid
    area2_pid = Madness.Story.Area.whereis area2_uuid

    :ok = Madness.Story.Area.add_condition(area1_pid,  "B", :eq,  {:b, true})
    :ok = Madness.Story.Area.add_condition(area1_pid, "^B", :neq, {:b, true})
    :ok = Madness.Story.Area.add_condition(area2_pid,  "B", :eq,  {:b, true})

    Madness.Story.Area.add_say(area1_pid, :plain, "ABC")
    Madness.Story.Area.add_say(area1_pid, "B", :plain, "DEF")
    Madness.Story.Area.add_say(area1_pid, :plain, "GHI")

    Madness.Story.Area.add_say(area2_pid, :plain, "123")
    Madness.Story.Area.add_say(area2_pid, "B", :plain, "456")
    Madness.Story.Area.add_say(area2_pid, :plain, "789")

    Madness.Story.Area.add_step(area1_pid, "^B", "test1", "Test A")
    Madness.Story.Area.add_transition_command(area1_pid, "test1", area2_uuid)
    Madness.Story.Area.add_state_command_set(area1_pid, "test1", :b, true)

    Madness.Story.Area.add_step(area2_pid, "test2", "Test B")
    Madness.Story.Area.add_transition_command(area2_pid, "test2", area1_uuid)

    Madness.Story.Area.add_step(area1_pid, "B", "test3", "Test C")
    Madness.Story.Area.add_state_command_set(area1_pid, "test3", :b, false)

    player_sup_pid = Madness.Players.Supervisor.whereis
    {:ok, player_uuid} = Madness.Players.Supervisor.add_player(player_sup_pid)
    player_pid = Madness.Player.whereis(player_uuid)
    assert is_pid(player_pid)
    :ok = Madness.Player.add_story(player_pid, story_uuid)
    :ok = Madness.Player.set_story(player_pid, story_uuid)
    story = Madness.Player.get_story(player_pid)
    assert story == story_uuid

    choices = Madness.Player.get_choices(player_pid)
    assert choices == [{"test1", "Test A"}]
    says = Madness.Player.say_story(player_pid)
    assert says == [{:plain, "ABC"}, {:plain, "GHI"}]

    :ok = Madness.Player.make_choice(player_pid, "test1")
    choices = Madness.Player.get_choices(player_pid)
    assert choices == [{"test2", "Test B"}]
    says = Madness.Player.say_story(player_pid)
    assert says == [{:plain, "123"}, {:plain, "456"}, {:plain, "789"}]

    :ok = Madness.Player.make_choice(player_pid, "test2")
    choices = Madness.Player.get_choices(player_pid)
    assert choices == [{"test3", "Test C"}]
    says = Madness.Player.say_story(player_pid)
    assert says == [{:plain, "ABC"}, {:plain, "DEF"}, {:plain, "GHI"}]
  end
end
