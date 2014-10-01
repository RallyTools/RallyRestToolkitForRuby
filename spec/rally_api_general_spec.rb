require_relative "spec_helper"

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
    @rally = RallyAPI::RallyRestJson.new(load_api_config)
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
    expect(tag1.nil?).to eq(false)

    obj["Tags"] = [tag1]

    new_st = @rally.create(:story, obj)
    expect(new_st.Name).to eq(obj["Name"])
    expect(new_st.Tags.nil?).to eq(false)
    first_tag = new_st.Tags[0].read
    expect(first_tag["Name"]).to eq(USE_TAGNAME)
  end

  it "should be able to create a story and tasks" do
    obj = {}
    obj["Name"] = "Test Story for Tasks created #{DateTime.now()}"
    obj["Description"] = "Test Description"
    new_st = @rally.create(:story, obj)
    expect(new_st.Name).to eq(obj["Name"])

    task_obj = { "Name" => "Test Task created on #{DateTime.now()}" }
    task_obj["WorkProduct"] = new_st
    new_task = @rally.create(:task, task_obj)
    expect(new_task.nil?).to eq(false)
    expect(new_task["WorkProduct"]["_ref"]).to eq(new_st["_ref"])
  end

  context '#allowed_values', allowed_values: true do
    context 'in default workspace' do
      it 'gets allowed values' do
        allowed_sevs = @rally.allowed_values("Defect", "Severity")
        expect(allowed_sevs.length).to be > 2
        allowed_states = @rally.allowed_values(:story, "ScheduleState")
        expect(allowed_states.length).to be > 3
        found = false
        allowed_states.each_key do |st|
          found = true if st == "Accepted"
        end
        expect(found).to be true
        allowed_hr_states = @rally.allowed_values("HierarchicalRequirement", "ScheduleState")
        expect(allowed_hr_states.length).to be > 3
      end
    end

    context 'in non-default workspace' do
      let(:headers) do
        RallyAPI::CustomHttpHeader.new( { :name => "Rally Rspec Utils", 
                                          :version => 'v2.0', 
                                          :vendor => "Rally" } )
      end

      it 'gets workspace-scoped allowed values in WSAPI v2.0' do
        # Note: This test requires that the non-default workspace has different
        #       allowed values for Defect ScheduleState

        # Setup
        @conf = YAML.load_file('spec/support/configs/APIconfig_nondefaultws.yml')
        # Connect to default workspace
        d_config =
          { :base_url   =>  @conf['RallyURL'] + '/slm',
          :username     =>  @conf['Username'],
          :password     =>  @conf['Password'],
          :workspace    =>  @conf['Default_WS'],
          :version      => 'v2.0',
          :headers      => headers,
          :debug        => false }
        d_rally = RallyAPI::RallyRestJson.new(d_config)
        d_workspace = d_rally.find_workspace(d_config['Workspace'])
        # Connect to non-default workspace with unique allowed values
        nd_config = d_config.merge(workspace: @conf['NonDefault_WS'])
        nd_rally = RallyAPI::RallyRestJson.new(nd_config)
        nd_workspace = nd_rally.find_workspace(nd_config['Workspace'])

        # Get allowed-values that are unique to each workspace 
        default_ws_values = d_rally.allowed_values("Defect", "ScheduleState", d_workspace)
        nondefault_ws_values = nd_rally.allowed_values("Defect", "ScheduleState", nd_workspace)

        # Verify this non-default workspace has different allowed values
        expect(default_ws_values).not_to eq(nondefault_ws_values)
      end
    end
  end

  it "should get the field list for defect" do
    fields = @rally.get_fields_for("defect")
    expect(fields).not_to be_nil
    expect(fields["State"]).not_to be_nil
    expect(fields["as;dfklasdf"]).to be_nil
  end

  it "should get the field list for stories" do
    fields = @rally.get_fields_for("story")
    expect(fields).not_to be_nil
    expect(fields["ScheduleState"]).not_to be_nil
    expect(fields["State"]).to be_nil
    expect(fields["as;dfklasdf"]).to be_nil
  end

  it "should get the field list for tasks" do
    fields = @rally.get_fields_for("task")
    expect(fields).not_to be_nil
    expect(fields["State"]).not_to be_nil
    expect(fields["as;dfklasdf"]).to be_nil
  end

  it "should get the custom fields for defects" do
    custom_fields = @rally.custom_fields_for("defect")
    expect(custom_fields).not_to be_nil
  end

end