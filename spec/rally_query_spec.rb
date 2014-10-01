require_relative "spec_helper"


describe "Rally Query Tests" do

  #setup 3 defects and stories for the tests below
  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)

    @base_name = "rally_api Test - #{Time.now}"
    story_fields  = {:Name => "#{@base_name.to_s} - #{rand()}", :Description => "Test for rally_api"}
    defect_fields = {:Name => "#{@base_name.to_s} - #{rand()}", :State => "Submitted", :Environment => "Test"}
    3.times do
      @rally.create(:story, story_fields)
      @rally.create(:defect, defect_fields)
    end

    @testrally_objects = {"defect" => "Defect"}

    #test hash for info below
    @query_hash = {}
    @query_hash[:type] = :defect
    @query_hash[:query_string] = "(State = \"Closed\")"
    @query_hash[:fetch] = "Name,State,etc"
    @query_hash[:project_scope_up] = false
    @query_hash[:project_scope_down] = true
    @query_hash[:order] = "ObjectID asc"
    @query_hash[:page_size] = 100
    @query_hash[:limit] = 1000
  end

  it "should throw an error for no object type" do
    test_hash = {}
    test_query = RallyAPI::RallyQuery.new(test_hash)
    expect(test_query.validate().length).to be > 0
  end

  it "should throw an error for a bad pagesize" do
    test_hash = {}
    test_hash[:pagesize] = 9999

    test_query = RallyAPI::RallyQuery.new(test_hash)
    expect(test_query.validate().length).to be > 0
  end

  it "should form a query based on a query hash" do
    test_query = RallyAPI::RallyQuery.new(@query_hash)
    expect(test_query.validate().length).to eq(0)
    params = test_query.make_query_params

    expect(params[:query]).to             eq(@query_hash[:query_string])
    expect(params[:fetch]).to             eq(@query_hash[:fetch])
    expect(params[:workspace].nil?).to    eq(true)
    expect(params[:project].nil?).to      eq(true)
    expect(params[:projectScopeUp]).to    eq(@query_hash[:project_scope_up])
    expect(params[:projectScopeDown]).to  eq(@query_hash[:project_scope_down])
    expect(params[:order]).to             eq(@query_hash[:order])
    expect(params[:pagesize]).to          eq(@query_hash[:page_size])
  end

  it "should form a query by setting the member variables" do
    test_query = RallyAPI::RallyQuery.new

    #defaults
    expect(test_query.page_size).to           eq(200)
    expect(test_query.limit).to               eq(99999)
    expect(test_query.project_scope_up).to    eq(false)
    expect(test_query.project_scope_down).to  eq(false)

    test_query.type = :defect
    test_query.fetch = "true"

    test_query.search = "foo"
    test_query.types = "hierarchicalrequirement,portfolioitem/feature"

    expect(test_query.validate().length).to eq(0)

    params = test_query.make_query_params

    expect(params[:query].nil?).to        eq(true)
    expect(params[:fetch]).to             eq("true")
    expect(params[:workspace].nil?).to    eq(true)
    expect(params[:project].nil?).to      eq(true)
    expect(params[:projectScopeUp]).to    eq(false)
    expect(params[:projectScopeDown]).to  eq(false)
    expect(params[:order].nil?).to        eq(true)
    expect(params[:pagesize]).to          eq(200)
    expect(params[:search]).to            eq("foo")
    expect(params[:types]).to             eq("hierarchicalrequirement,portfolioitem/feature")
  end


  it "should make a query from a hash" do
    qh = {}
    limit = 20
    qh[:type]  = :defect
    qh[:fetch] = "Name"
    qh[:limit] = limit

    test_query = RallyAPI::RallyQuery.new(qh)
    expect(test_query.type).to  eq("defect")
    expect(test_query.limit).to eq(limit)
  end

  it "should make a query and allow setting type by property" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = "defect"
    test_query.fetch = "Name"

    expect(test_query.type).to eq("defect")
  end

  it "should validate a query" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"

    expect(test_query.validate().length).to eq(0)
  end

  it "should throw an error for a bad query workspace and project" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"
    test_query.workspace = "bucky"
    test_query.project = "badger"

    expect(test_query.validate().length).to be > 1
    expect { @rally.find(test_query) }.to raise_exception(/Errors making Rally Query/)
  end

  it "should throw an error for a bad query pagesize or limit" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"
    test_query.page_size = -1
    test_query.limit = -1

    expect(test_query.validate().length).to be > 1
    expect { @rally.find(test_query) }.to raise_exception(/Errors making Rally Query/)
  end

  it "should find defects" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect
    test_query.fetch = "Name"
    test_query.page_size = 50
    test_query.limit = 100
    test_query.query_string = "(Name contains \"#{@base_name.to_s}\")"

    query_result = @rally.find(test_query)
    expect(query_result.total_result_count).to eq(3)

    expect(query_result.results[0]["Name"]).to match(/#{@base_name.to_s}/)
  end

  #note -this test assumes a workspace with more than 10 defects
  it "find should work with small limits and pagesize" do
    qh = {:type => "defect", :fetch => "Name", :page_size => 5, :limit => 10 }
    test_query = RallyAPI::RallyQuery.new(qh)
    query_result = @rally.find(test_query)
    #query_result.each_with_index { |de, ind| puts "#{ind} - #{de["Name"]}"}
    expect(query_result.length).to eq(10)
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

    expect(name_list.length).to be > 1
    expect(query_result.length).to eq(100)
  end

  it "should find stories with the :story alias" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :story
    test_query.fetch = "Name"
    test_query.page_size = 50
    test_query.limit = 100
    test_query.query_string =  "(Name contains \"#{@base_name.to_s}\")"

    query_result = @rally.find(test_query)
    expect(query_result.total_result_count).to eq(3)

    expect(query_result.results[0]["Name"]).to match(/#{@base_name.to_s}/)
  end

  it "should take a block in find and let you mod the query" do
    query_result = @rally.find do |query|
      query.type = :story
      query.fetch = "Name"
      query.page_size = 50
      query.limit = 100
      query.query_string = "(Name contains \"#{@base_name.to_s}\")"
    end

    expect(query_result.total_result_count).to eq(3)
    expect(query_result.results[0]["Name"]).to match(/#{@base_name.to_s}/)
  end

  it "should have warnings on the query result" do
    #API status is Deprecated and will become Not Supported on
    current_wsapi = @rally.wsapi_version
    @rally.wsapi_version = "1.37"
    query_result = @rally.find do |query|
      query.type = :story
      query.fetch = "Name"
      query.page_size = 50
      query.limit = 100
      query.query_string = "(Name contains \"#{@base_name.to_s}\")"
    end
    expect(query_result.warnings).not_to be_nil
    expect(query_result.warnings[0]).to include("Please update your client to use the latest version of the API.")
    @rally.wsapi_version = current_wsapi
  end

  it "should change threads safely" do
    @rally.adjust_find_threads(1)
    expect(@rally.rally_connection.find_threads).to eq(1)

    @rally.adjust_find_threads(2)
    expect(@rally.rally_connection.find_threads).to eq(2)

    @rally.adjust_find_threads(-1)
    expect(@rally.rally_connection.find_threads).to eq(1)

    @rally.adjust_find_threads(10)
    expect(@rally.rally_connection.find_threads).to eq(4)

    @rally.adjust_find_threads("abc")
    expect(@rally.rally_connection.find_threads).to eq(4)

    @rally.rally_connection.set_find_threads
    expect(@rally.rally_connection.find_threads).to eq(2)
  end

  #support the crazy query string structure for the api
  #each condition with an and or an or needs to be wrapped rpn style in ()
  it "should build complex query with helper functions" do
    test_query = RallyAPI::RallyQuery.new()
    test_query.type = :defect

    or1_text = '((Severity = "Major Problem") OR (Severity = "Crash/Data Loss"))'
    orand1_text = '(((Severity = "Major Problem") OR (Severity = "Crash/Data Loss")) AND (Priority = Low))'
    big_or_text = '(((Severity = "Major Problem") OR (Severity = "Crash/Data Loss")) OR (Severity = "Minor Problem"))'
    crazy_and_text = '(((Severity = "Major Problem") AND (Priority = "Low")) OR ((Severity = "Crash/Data Loss") AND (Priority = "Normal")))'

    or_conditions = ['Severity = "Major Problem"', 'Severity = "Crash/Data Loss"', 'Severity = "Minor Problem"']
    query_str = test_query.build_query_segment(or_conditions, "OR")
    expect(query_str).to eq(big_or_text)

    query_str = test_query.build_query_segment(or_conditions[0..1], "OR")
    expect(query_str).to eq(or1_text)

    query_str = test_query.add_and(query_str, "Priority = Low")
    expect(query_str).to eq(orand1_text)

    and_conditions1 = ['Severity = "Major Problem"', 'Priority = "Low"']
    and_conditions2 = ['Severity = "Crash/Data Loss"', 'Priority = "Normal"']
    and_str1 = test_query.build_query_segment(and_conditions1, "AND")
    and_str2  = test_query.build_query_segment(and_conditions2, "AND")
    query_str = test_query.add_or(and_str1, and_str2)
    expect(query_str).to eq(crazy_and_text)
  end


end