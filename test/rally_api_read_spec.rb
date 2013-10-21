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
    defect.ref.should == @test_defect.ref
    defect.Name.should == @test_defect.Name
  end

  it "should read an object from a formatted ID" do
    formattedid = @test_defect.FormattedID
    defect = @rally.read(:defect, "FormattedID|#{formattedid}")
    defect.ref.should == @test_defect.ref
    defect.Name.should == @test_defect.Name
  end

  it "should get a field by bracket reference" do
    @test_defect["Name"].should == @test_defect.Name
  end

  it "should get a secondary object via a read" do
    @test_defect.Owner.read.DisplayName.should == @rally.user.DisplayName
    @test_defect["Owner"].read["UserName"].should == @rally.user.UserName
  end

  it "should throw an exception for a read on a bad OID" do
    lambda { @rally.read(:defect, 123) }.should raise_exception(/Error on request -/)
  end

  it "should work from the other basic read example" do
    results = @rally.find(RallyAPI::RallyQuery.new({:type => :defect, :query_string => "(ObjectID = #{@test_defect.ObjectID})"}))
    defect = results.first
    defect.read
    defect.ref.should == @test_defect.ref
  end

  it "should conduct a find with a valid order" do
    defects = @rally.find do |q|
      q.type = :defect
      q.order = "Rank ASC"
    end
  end

  it "should conduct a find with an invalid order" do
    lambda do
      defects = @rally.find do |q|
        q.type = :defect
        q.order = "Invalid Order"
      end
    end.should raise_error(StandardError, /Cannot sort using unknown attribute Invalid/)
  end

  it "should conduct a find with an empty string order and it will not exception" do
    defects = @rally.find do |q|
      q.type = :defect
      q.order = ""
    end
  end
end
