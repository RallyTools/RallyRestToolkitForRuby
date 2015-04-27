require_relative "spec_helper"

describe "Rally Json Create Tests" do

  before :all do
    @rally = RallyAPI::RallyRestJson.new(load_api_config)
  end

  def setup_test_defect(fields = {})
    obj = fields
    obj["Name"] = "Test Defect created #{DateTime.now()}"
    obj["Environment"] = "Production"
    obj["TargetDate"] = Time.now
    obj
  end


  it "should create an object from a basic hash with ref" do
    obj = setup_test_defect
    new_de = @rally.create(:defect, obj)
    expect(new_de.Name).to eq(obj["Name"])
  end

  it "should throw an exception for a create on a bad artifact type" do
    obj = setup_test_defect
    expect { @rally.create(:bucky, obj) }.to raise_exception(StandardError, /Error on request/)
  end

  it "should create with a reference to another Object" do
    obj = {}
    obj["Name"] = "Test with a link to Owner"
    obj["Owner"] = @rally.user

    new_de = @rally.create(:defect, setup_test_defect(obj))
    expect(new_de.Name).to eq(obj["Name"])
    expect(new_de.Owner["_ref"]).to eq(@rally.user["_ref"])
  end
  
  it "should create with a web link field" do
    weblink_field_name = load_api_config_extras[:weblink_field_name]
    if weblink_field_name.nil?
      puts "Skipping test: WebLinkFieldName not present in config"
    else
      obj = {}
      obj["Name"] = "Test with a weblink"
      obj[weblink_field_name] = { "LinkID"=>"123", "DisplayString"=>"The Label" }
      new_de = @rally.create(:defect, setup_test_defect(obj))
      expect(new_de.Name).to eq(obj["Name"])
      expect(new_de[weblink_field_name]["LinkID"]).to eq("123")
      expect(new_de[weblink_field_name]["DisplayString"]).to eq("The Label")
    end
  end

  it "should raise an error on create if a field is required" do
    obj = {}
    obj["Name"] = ""

    expect { @rally.create(:defect, obj) }.to raise_exception(/Error on request -/)
  end

  it "should create an object and delete it" do
    obj = setup_test_defect
    new_de = @rally.create(:defect, obj)
    expect(new_de.Name).to eq(obj["Name"])
    delete_result = new_de.delete()
    expect { new_de.read }.to raise_exception(/Error on request -/)
  end

  it "should create with params to rank to bottom" do
    defect_hash = setup_test_defect({"Name" => "Test Defect bottom ranked - created #{DateTime.now()}"})
    defect_hash["Severity"] = "Major Problem"
    params = {:rankTo => "BOTTOM"}
    new_defect = @rally.create(:defect, defect_hash, params)
    expect(new_defect.Severity).to eq("Major Problem")
    bottom_defects = @rally.find do |q|
      q.type = :defect
      q.order = "Rank Desc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end
    expect(bottom_defects[0]["ObjectID"]).to eq(new_defect["ObjectID"])
  end

  it "should get warnings on create" do
    current_wsapi = @rally.wsapi_version
    @rally.wsapi_version = "1.37"
    obj = setup_test_defect
    obj["Name"] = "Test Defect created #{DateTime.now()} - wsapi warning check"
    new_de = @rally.create(:defect, obj)
    expect(new_de.Name).to eq(obj["Name"])
    expect(new_de.warnings).not_to be_nil
    expect(new_de.warnings[0]).to include("Please update your client to use the latest version of the API.")
    @rally.wsapi_version = current_wsapi
  end

end
