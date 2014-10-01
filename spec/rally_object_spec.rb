require_relative "spec_helper"

describe "Rally Json Object Tests" do

  JSON_TEST_OBJECT = { "Name" => "Test Name", "Severity" => "High", "_type" => "defect", "ScheduleState" => "In-Progress"}
  UPDATED_TEST_OBJECT = { "Name" => "Test Name", "Severity" => "High", "Priority" => "Very Important","_type" => "defect"}

  TASK1 = {"Name" => "Task 1", "_type" => "task"}
  TASK2 = {"Name" => "Task 2", "_type" => "task"}
  TASK3 = {"Name" => "Task 3", "_type" => "task"}
  TASK4 = {"Name" => "Task 4", "_type" => "task", "State" => "In-Progress"}
  CHILD_STORY1 = {"Name" => "Child 1", "Tasks" => [TASK1, TASK2], "_type" => "hierarchicalrequirement", "ScheduleState" => "Defined"}
  CHILD_STORY2 = {"Name" => "Child 2", "Tasks" => [TASK3, TASK4], "_type" => "hierarchicalrequirement", "ScheduleState" => "Defined"}
  NESTED_STORY = {"Name" => "Parent Story", "Children" => [CHILD_STORY1, CHILD_STORY2], "_type" => "hierarchicalrequirement", "ScheduleState" => "Defined"}

  before :each do
    @mock_rally = double("MockRallyRest")
    allow(@mock_rally).to receive_messages(:reread => UPDATED_TEST_OBJECT)
    allow(@mock_rally).to receive_messages(:rally_rest_api_compat => false)
  end

  it "should load a basic json hash" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    expect(test_object.nil?).to eq(false)
    expect(test_object.Name).to eq("Test Name")
  end

  it "should call reread for a nil value" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    test_object.read()
    expect(test_object.Priority).to eq("Very Important")
  end

  it "should be able to access a field with [] notation" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    expect(test_object["Severity"]).to eq("High")
  end

  it "should read a nested object attribute" do
    test_object = RallyAPI::RallyObject.new(@mock_rally, NESTED_STORY)

    expect(test_object.Children[1].Tasks[1].Name).to eq(TASK4["Name"])
    expect(test_object.Children[1].Name).to eq(CHILD_STORY2["Name"])
  end

  it "should return nil for field that has no value" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    expect(test_object.nil?).to eq(false)
    expect(test_object.Foo.nil?).to eq(true)
  end

  it "should return a nil without lazy loading" do
    test_object = RallyAPI::RallyObject.new(@mock_rally, NESTED_STORY)
    expect(@mock_rally).to receive(:rally_rest_api_compat)
    expect(test_object.nil?).to eq(false)
    expect(test_object.Foo.nil?).to eq(true)
    expect(test_object.Severity.nil?).to eq(true)
    expect(test_object.Children[1].Name.nil?).to eq(false)
  end

  it "should allow setting a field by []" do
    test_object = RallyAPI::RallyObject.new(@mock_rally, NESTED_STORY)
    expect(test_object.nil?).to eq(false)
    new_desc = "A new description"
    test_object["Description"] = new_desc
    expect(test_object.Description).to eq(new_desc)
  end

  it "should respect the RallyRestAPI compatibility flag when reading a field" do
    mock_rally_with_compat = double("MockRallyRest")
    allow(mock_rally_with_compat).to receive_messages(:rally_rest_api_compat => true)
    test_object = RallyAPI::RallyObject.new(mock_rally_with_compat, NESTED_STORY)
    expect(test_object.schedule_state).to eq(NESTED_STORY["ScheduleState"])
    expect(test_object.to_s).to eq(NESTED_STORY["Name"])
    expect(test_object.name).to eq(NESTED_STORY["Name"])
    expect(test_object.children["Child 1"].name).to eq(CHILD_STORY1["Name"])
  end

  it "should return a rally collection for an array" do
    test_object = RallyAPI::RallyObject.new(@mock_rally, CHILD_STORY2)
    expect(test_object.Tasks.class.name).to eq("RallyAPI::RallyCollection")
    expect(test_object.Tasks["Task 4"].State).to eq("In-Progress")
  end

  it "should be able to add to a RallyCollection" do
    test_object = RallyAPI::RallyObject.new(@mock_rally, CHILD_STORY2)
    test_object["Tasks"] << {"Name" => "added task to RallyCollection", "_type" => "task"}
    expect(test_object["Tasks"].length).to eq(3)
  end

end