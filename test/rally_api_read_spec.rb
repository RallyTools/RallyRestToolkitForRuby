require "rspec"
require_relative "rally_api_spec_helper"
require "time"

describe "Rally Json Read Tests" do

  #Side note - trying to keep things from getting too cluttered
  # hence the before all instead of before each
  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
    fields = {"Name" => "rally_api tests - Defect #{Time.now}", "Owner" => @rally.user}
    @test_defect = @rally.create(:defect, fields)
  end

  it "should read an object from an objectID" do
    defect = @rally.read(:defect, @test_defect.ObjectID)
    expect(defect.ref).to eq(@test_defect.ref)
    expect(defect.Name).to eq(@test_defect.Name)
  end

  it "should read an object from a formatted ID" do
    formattedid = @test_defect.FormattedID
    defect = @rally.read(:defect, "FormattedID|#{formattedid}")
    expect(defect.ref).to eq(@test_defect.ref)
    expect(defect.Name).to eq(@test_defect.Name)
  end

  it "should get a field by bracket reference" do
    expect(@test_defect["Name"]).to eq(@test_defect.Name)
  end

  it "should get a secondary object via a read" do
    expect(@test_defect.Owner.read.DisplayName).to eq(@rally.user.DisplayName)
    expect(@test_defect["Owner"].read["UserName"]).to eq(@rally.user.UserName)
  end

  it "should throw an exception for a read on a bad OID" do
    expect { @rally.read(:defect, 123) }.to raise_exception(/Error on request -/)
  end

  it "should work from the other basic read example" do
    results = @rally.find(RallyAPI::RallyQuery.new({:type => :defect, :query_string => "(ObjectID = #{@test_defect.ObjectID})"}))
    defect = results.first
    defect.read
    expect(defect.ref).to eq(@test_defect.ref)
  end

  it "should conduct a find with a valid order", todo: true do
    defects = @rally.find do |q|
      q.type = :defect
      # q.order = "Rank ASC"
      q.order = "Rank FooBar"
    end
    # TODO: Update to ensure an appropriate warning is generated in WSAPI 2.0
    expect(defects.warnings.first).to match(/Please update your client to use the latest version of the API/)
    expect(defects.warnings.length).to eq(1)
  end

  it "should conduct a find with an invalid order" do
    expect do
      defects = @rally.find do |q|
        q.type = :defect
        q.order = "Invalid Order"
      end
    end.to raise_error(StandardError, /Cannot sort using unknown attribute Invalid/)
  end

  it "should conduct a find with an empty string order and it will not exception", todo: true do
    defects = @rally.find do |q|
      q.type = :defect
      q.order = ""
    end
    # TODO: Update to ensure an appropriate warning is generated in WSAPI 2.0
    expect(defects.warnings.first).to match(/Please update your client to use the latest version of the API/)
    expect(defects.warnings.length).to eq(1)
    # Warning: No sort criteria has been defined.  The sort order will be unpredictable.
    # Between 10/10 and 10/21
  end
end
