require "rspec"

require_relative "rally_api_spec_helper"
require_relative "../lib/rally_api/rally_object"

describe "Rally Json Objects" do

  JSON_TEST_OBJECT = { "Name" => "Test Name", "Severity" => "High", "_type" => "defect"}
  UPDATED_TEST_OBJECT = { "Name" => "Test Name", "Severity" => "High", "Priority" => "Very Important","_type" => "defect"}

  TASK1 = {"Name" => "Task 1", "_type" => "task"}
  TASK2 = {"Name" => "Task 2", "_type" => "task"}
  TASK3 = {"Name" => "Task 3", "_type" => "task"}
  TASK4 = {"Name" => "Task 4", "_type" => "task"}
  CHILD_STORY1 = {"Name" => "Child 1", "Tasks" => [TASK1, TASK2], "_type" => "hierarchicalrequirement"}
  CHILD_STORY2 = {"Name" => "Child 2", "Tasks" => [TASK3, TASK4], "_type" => "hierarchicalrequirement"}
  NESTED_STORY = {"Name" => "Parent Story", "Children" => [CHILD_STORY1, CHILD_STORY2], "_type" => "hierarchicalrequirement"}

  before :each do
    @mock_rally = double("MockRallyRest")
    @mock_rally.stub(:reread => UPDATED_TEST_OBJECT)
    @mock_rally.stub(:rally_rest_api_compat => false)
  end

  it "should load a basic json hash" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    test_object.nil?.should == false
    test_object.Name.should == "Test Name"
  end

  it "should call reread for a nil value" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    test_object.read()
    test_object.Priority.should == "Very Important"
  end

  it "should be able to access a field with [] notation" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    test_object["Severity"].should == "High"
  end

  it "should read a nested object attribute" do
    test_object = RallyAPI::RallyObject.new(@mock_rally, NESTED_STORY)

    test_object.Children[1].Tasks[1].Name.should == TASK4["Name"]
    test_object.Children[1].Name.should == CHILD_STORY2["Name"]
  end

  it "should return nil for field that has no value" do
    test_object = RallyAPI::RallyObject.new(@mock_rally,JSON_TEST_OBJECT)
    test_object.nil?.should == false
    test_object.Foo.nil?.should == true
  end

  it "should return a nil without lazy loading" do
    test_object = RallyAPI::RallyObject.new(@mock_rally, NESTED_STORY)
    test_object.nil?.should == false
    test_object.Foo.nil?.should == true
    test_object.Severity.nil?.should == true
    test_object.Children[1].Name.nil?.should == false
  end

end