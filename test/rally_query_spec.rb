require "rspec"
require_relative "rally_api_spec_helper"
require_relative "../lib/rally_api/rally_query"
require "time"

describe "Rally Query Tests" do

  #setup 3 defects and stories for the tests below
  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)

    @base_name = "rally_api Test - #{Time.now}"
    story_fields = { :Name => "#{@base_name.to_s} - #{rand()}", :Description => "Test for rally_api"}
    defect_fields = {:Name => "#{@base_name.to_s} - #{rand()}", :State => "Submitted"}
    3.times do
      @rally.create(:story, story_fields)
      @rally.create(:defect, defect_fields)
    end
  end

  #test hash for info below
  query_hash = {}
  query_hash[:type] = :defect
  query_hash[:query_string] = "(State = \"Closed\")"
  query_hash[:fetch] = "Name,State,etc"
  query_hash[:project_scope_up] = false
  query_hash[:project_scope_down] = true
  query_hash[:order] = "ObjectID asc"
  query_hash[:page_size] = 100
  query_hash[:limit] = 1000

  it "should throw an error for a bad object type" do
    test_hash = {}
    test_hash[:type] = "Bucky"

    test_query = RallyAPI::RallyQuery.new(test_hash)
    test_query.validate({}).length.should > 0
  end

  it "should throw an error for a bad pagesize" do
    test_hash = {}
    test_hash[:pagesize] = 9999

    test_query = RallyAPI::RallyQuery.new(test_hash)
    test_query.validate({}).length.should > 0
  end

  it "should form a query based on a query hash" do
    test_query = RallyAPI::RallyQuery.new(query_hash)
    test_query.validate({:defect => "Defect"}).length.should == 0
    params = test_query.make_query_params

    params[:query].should             == query_hash[:query_string]
    params[:fetch].should             == query_hash[:fetch]
    params[:workspace].nil?.should    == true
    params[:project].nil?.should      == true
    params[:projectScopeUp].should    == query_hash[:project_scope_up]
    params[:projectScopeDown].should  == query_hash[:project_scope_down]
    params[:order].should             == query_hash[:order]
    params[:pagesize].should          == query_hash[:page_size]
  end

  it "should form a query by setting the member variables" do
    test_query = RallyAPI::RallyQuery.new

    #defaults
    test_query.page_size.should           == 200
    test_query.limit.should               == 99999
    test_query.project_scope_up.should    == false
    test_query.project_scope_down.should  == false

    test_query.type = :defect
    test_query.fetch = "true"

    test_query.validate({:defect => "Defect"}).length.should == 0

    params = test_query.make_query_params

    params[:query].nil?.should         == true
    params[:fetch].should             == "true"
    params[:workspace].nil?.should    == true
    params[:project].nil?.should      == true
    params[:projectScopeUp].should    == false
    params[:projectScopeDown].should  == false
    params[:order].nil?.should        == true
    params[:pagesize].should          == 200
  end


  it "should make a query from a hash" do
    qh = {}
    qh[:type] = :defect
    qh[:fetch] = "Name"

    test_query = RallyAPI::RallyQuery.new(qh)

    test_query.type.should == :defect
  end

  it "should make a query and allow setting type by property" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"

    test_query.type.should == :defect
  end

  it "should validate a query" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"

    test_query.validate({:defect => "Defect"}).length.should == 0
  end

  it "should throw an error for a bad query type" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :bucky
    test_query.fetch = "Name"

    test_query.validate({:defect => "Defect"}).length.should > 0
    lambda { @rally.find(test_query) }.should raise_exception(/Errors making Rally Query/)
  end

  it "should throw an error for a bad query workspace and project" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"
    test_query.workspace = "bucky"
    test_query.project = "badger"

    test_query.validate({:defect => "Defect"}).length.should > 1
    lambda { @rally.find(test_query) }.should raise_exception(/Errors making Rally Query/)
  end

  it "should throw an error for a bad query pagesize or stop after" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"
    test_query.page_size = -1
    test_query.limit = -1

    test_query.validate({:defect => "Defect"}).length.should > 1
    lambda { @rally.find(test_query) }.should raise_exception(/Errors making Rally Query/)
  end

  it "should find defects" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"
    test_query.page_size = 50
    test_query.limit = 100
    test_query.query_string = "(Name contains \"#{@base_name.to_s}\")"

    query_result = @rally.find(test_query)
    query_result.total_result_count.should == 3

    query_result.results[0]["Name"].should match(/#{@base_name.to_s}/)
  end

  it "should loop over more than a page of query results" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :story
    test_query.fetch = "Name"
    test_query.page_size = 20
    test_query.limit = 100

    query_result = @rally.find(test_query)
    name_list = ""
    query_result.each do |story|
      name_list << ",#{story.Name}"
    end

    name_list.length.should > 1
    query_result.length.should == 100
  end

  it "should find stories with the :story alias" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :story
    test_query.fetch = "Name"
    test_query.page_size = 50
    test_query.limit = 100
    test_query.query_string =  "(Name contains \"#{@base_name.to_s}\")"

    query_result = @rally.find(test_query)
    query_result.total_result_count.should == 3

    query_result.results[0]["Name"].should match(/#{@base_name.to_s}/)
  end

  it "should take a block in find and let you mod the query" do
    query_result = @rally.find do |query|
      query.type = :story
      query.fetch = "Name"
      query.page_size = 50
      query.limit = 100
      query.query_string = "(Name contains \"#{@base_name.to_s}\")"
    end

    query_result.total_result_count.should == 3
    query_result.results[0]["Name"].should match(/#{@base_name.to_s}/)
  end



end