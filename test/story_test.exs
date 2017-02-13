defmodule StoryTest do
  use ExUnit.Case
  doctest Madness.Story

  test "the truth" do
    assert 1 + 1 == 2
  end
  test "Make a story" do
    story_sup_pid = Madness.Stories.Supervisor.whereis
    {:ok, story_uuid} = Madness.Stories.Supervisor.add_story story_sup_pid
    story_pid = Madness.Story.whereis story_uuid
    {:ok, area_uuid} = Madness.Story.add_area story_pid
    area_pid = Madness.Story.Area.whereis area_uuid
    Madness.Story.Area.add_say(area_pid, :plain, "You wander an aimless road.")
    Madness.Story.Area.add_say(area_pid, :plain, "It smells like fish.")
    Madness.Story.Area.add_say(area_pid, "B", :plain, "It does not seem to lead anywhere.", 1)

    Madness.Story.Area.add_condition(area_pid, "B", :eq, {:b, true})

    {:ok, says} = Madness.Story.Area.list_says(area_pid, %{})
    assert says == [
      {:plain, "You wander an aimless road."},
      {:plain, "It smells like fish."}
    ]

    {:ok, says} = Madness.Story.Area.list_says(area_pid, %{b: true})
    assert says == [
      {:plain, "You wander an aimless road."},
      {:plain, "It does not seem to lead anywhere."},
      {:plain, "It smells like fish."}
    ]

  end

  test "Multiple steps" do
    story_sup_pid = Madness.Stories.Supervisor.whereis
    {:ok, story_uuid} = Madness.Stories.Supervisor.add_story story_sup_pid
    story_pid = Madness.Story.whereis story_uuid
    {:ok, area_uuid} = Madness.Story.add_area story_pid
    area_pid = Madness.Story.Area.whereis area_uuid

    Madness.Story.Area.add_step(area_pid, "test1", "Test A")
    Madness.Story.Area.add_step(area_pid, "B", "test2", "Test B")
    Madness.Story.Area.add_step(area_pid, "test3", "Test C")
    Madness.Story.Area.add_condition(area_pid, "B", :eq, {:b, true})

    {:ok, steps} = Madness.Story.Area.list_steps(area_pid, %{})
    assert steps == [
      {"test1", "Test A"},
      {"test3", "Test C"}
    ]

    {:ok, steps} = Madness.Story.Area.list_steps(area_pid, %{b: true})
    assert steps == [
      {"test1", "Test A"},
      {"test2", "Test B"},
      {"test3", "Test C"}
    ]

  end

  test "Transitions" do
    story_sup_pid = Madness.Stories.Supervisor.whereis
    {:ok, story_uuid} = Madness.Stories.Supervisor.add_story story_sup_pid
    story_pid = Madness.Story.whereis story_uuid

    {:ok, area1_uuid} = Madness.Story.add_area story_pid
    {:ok, area2_uuid} = Madness.Story.add_area story_pid
    area1_pid = Madness.Story.Area.whereis area1_uuid
    area2_pid = Madness.Story.Area.whereis area2_uuid

    
    Madness.Story.Area.add_step(area1_pid, "test1", "Test A")
    Madness.Story.Area.add_transition_command(area1_pid, "test1", area2_uuid)

    Madness.Story.Area.add_step(area2_pid, "test2", "Test B")
    Madness.Story.Area.add_transition_command(area2_pid, "test2", area1_uuid)

    {:ok, comms} = Madness.Story.Area.list_step_commands(area1_pid, "test1")
    assert comms == [
      {:transition, area2_uuid}
    ]

    {:ok, comms} = Madness.Story.Area.list_step_commands(area2_pid, "test2")
    assert comms == [
      {:transition, area1_uuid}
    ]
  end
end
