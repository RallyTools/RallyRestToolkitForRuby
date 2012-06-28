require "rspec"
require_relative "rally_api_spec_helper"

describe "Rally Json Update Tests" do

  #Side note - trying to keep things from getting too cluttered
  # hence the before all instead of before each
  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
    fields = {"Name" => "rally_api tests - Defect #{Time.now}", "Owner" => @rally.user}
    @test_defect = @rally.create(:defect, fields)
    @test_story = @rally.create(:story, {"Name" => "rally_api tests - Story #{Time.now}", "Owner" => @rally.user, "Description" => "test"} )
  end

  it "should update an object from a basic hash with ref" do
    defect_hash = {}
    defect_hash["Severity"] = "Major Problem"
    defect_hash["Description"] = "Description for the issue"
    updated_defect = @rally.update(:defect, @test_defect.ObjectID, defect_hash)
    updated_defect.Severity.should == "Major Problem"
  end

  it "should update an artifact by calling update on the object" do
    field_updates = { "Description" => "Changed Description" }
    @test_defect.update(field_updates)
    @test_defect.Description.should == "Changed Description"
  end

  it "should throw an exception for an update on a bad OID" do
    defect_hash = {}
    defect_hash["Severity"] = "Major Problem"
    defect_hash["Description"] = "Description for the issue"
    lambda {@rally.update(:defect, 123 , defect_hash)}.should raise_exception(/Error on request/)
  end

  it "should report errors and warnings for bad fields in the update" do
    field_updates = { "Bucky" => "Badger", "Severity" => "Brutal" }
    lambda { @test_defect.update(field_updates) }.should raise_error(/Error on request/)
  end

  it "should update a story via the story alias" do
    st_hash = {}
    new_est = rand(10)
    st_hash["PlanEstimate"] = new_est
    st_hash["Description"] = "Description for the issue"
    updated_item = @rally.update(:story, @test_story.ObjectID, st_hash)
    updated_item.PlanEstimate.should == new_est
  end

  it "should rank relative to" do
    story1_rank = @test_story["Rank"]
    story1_rank.should be > 0

    new_rank1 = @test_defect.rank_above(@test_story).Rank
    #puts "rank1 is #{new_rank1}"
    new_rank1.should be < story1_rank

    new_rank2 = @test_defect.rank_below(@test_story).Rank
    #puts "rank2 is #{new_rank2}"
    new_rank2.should be > story1_rank
  end

end
