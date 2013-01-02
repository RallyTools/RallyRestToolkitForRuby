require "rspec"
require_relative "rally_api_spec_helper"

describe "Rally API specific artifact tests" do

  USE_TAGNAME = "zzTag1"

  def find_tag(tagname)
    tg_query = RallyAPI::RallyQuery.new()
    tg_query.type = :tag
    tg_query.query_string = "(Name = \"#{tagname}\")"
    tg_query.limit=20

    tg_result = @rally.find(tg_query)
    tg_result.first
  end

  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
    tag1 = find_tag(USE_TAGNAME)
    if tag1.nil?
      @rally.create(:tag, {"Name" => USE_TAGNAME})
    end
  end

  it "should be able to set tags with tag object" do
    obj = {}
    obj["Name"] = "Test Story for Tags created #{DateTime.now()}"
    obj["Description"] = "Test Description"

    tag1 = find_tag(USE_TAGNAME)
    tag1.nil?.should == false

    obj["Tags"] = [tag1]

    new_st = @rally.create(:story, obj)
    new_st.Name.should == obj["Name"]
    new_st.Tags.nil?.should == false
    first_tag = new_st.Tags[0].read
    first_tag["Name"].should == USE_TAGNAME
  end

  it "should be able to create a story and tasks" do
    obj = {}
    obj["Name"] = "Test Story for Tasks created #{DateTime.now()}"
    obj["Description"] = "Test Description"
    new_st = @rally.create(:story, obj)
    new_st.Name.should == obj["Name"]

    task_obj = { "Name" => "Test Task created on #{DateTime.now()}" }
    task_obj["WorkProduct"] = new_st
    new_task = @rally.create(:task, task_obj)
    new_task.nil?.should == false
    new_task["WorkProduct"]["_ref"].should == new_st["_ref"]
  end

  it "should get allowed values for artfiacts" do
    allowed_sevs = @rally.allowed_values("Defect", "Severity")
    allowed_sevs.length.should > 2
    #allowed_sevs.each_key do |sev|
    #  puts sev
    #end
    allowed_states = @rally.allowed_values(:story, "ScheduleState")
    allowed_states.length.should > 3
    found = false
    allowed_states.each_key do |st|
      #puts st
      found = true if st == "Accepted"
    end
    found.should be_true
    allowed_hr_states = @rally.allowed_values("HierarchicalRequirement", "ScheduleState")
    allowed_hr_states.length.should > 3
  end

  it "should get the field list for defect" do
    fields = @rally.get_fields_for("defect")
    fields.should_not be_nil
    fields["State"].should_not be_nil
    fields["as;dfklasdf"].should be_nil
  end

  it "should get the field list for stories" do
    fields = @rally.get_fields_for("story")
    fields.should_not be_nil
    fields["ScheduleState"].should_not be_nil
    fields["State"].should be_nil
    fields["as;dfklasdf"].should be_nil
  end

  it "should get the field list for tasks" do
    fields = @rally.get_fields_for("task")
    fields.should_not be_nil
    fields["State"].should_not be_nil
    fields["as;dfklasdf"].should be_nil
  end

end