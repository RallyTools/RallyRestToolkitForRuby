require_relative "spec_helper"

describe "Rally Json Update Tests" do

  #Side note - trying to keep things from getting too cluttered
  # hence the before all instead of before each
  before :all do
    @rally = RallyAPI::RallyRestJson.new(load_api_config)
    fields = {"Name" => "rally_api tests - Defect #{Time.now}", "Owner" => @rally.user}
    @test_defect = @rally.create(:defect, fields)
    @test_story = @rally.create(:story, {"Name" => "rally_api tests - Story #{Time.now}", "Owner" => @rally.user, "Description" => "test"} )
  end

  it "should update an object from a basic hash with ref" do
    defect_hash = {}
    defect_hash["Severity"] = "Major Problem"
    defect_hash["Description"] = "Description for the issue"
    updated_defect = @rally.update(:defect, @test_defect.ObjectID, defect_hash)
    expect(updated_defect.Severity).to eq("Major Problem")
  end

  it "should update an artifact by calling update on the object" do
    field_updates = { "Description" => "Changed Description" }
    @test_defect.update(field_updates)
    expect(@test_defect.Description).to eq("Changed Description")
  end

  it "should throw an exception for an update on a bad OID" do
    defect_hash = {}
    defect_hash["Severity"] = "Major Problem"
    defect_hash["Description"] = "Description for the issue"
    expect {@rally.update(:defect, 123 , defect_hash)}.to raise_exception(/Error on request/)
  end

  it "should report errors and warnings for bad fields in the update" do
    field_updates = { "Bucky" => "Badger", "Severity" => "Brutal" }
    expect { @test_defect.update(field_updates) }.to raise_error(/Error on request/)
  end

  it "should update a story via the story alias" do
    st_hash = {}
    new_est = rand(10)
    st_hash["PlanEstimate"] = new_est
    st_hash["Description"] = "Description for the issue"
    updated_item = @rally.update(:story, @test_story.ObjectID, st_hash)
    expect(updated_item.PlanEstimate).to eq(new_est)
  end

  it "should update directly on RallyObject and get a Rally Object back" do
    new_desc = "New Description via update"
    updated_de = @test_defect.update({:Description => new_desc, :TargetDate => Time.now})
    expect(updated_de.class.name).to eq("RallyAPI::RallyObject")
    expect(updated_de.Description).to eq(new_desc)
  end

  it "should be able to update a PI/feature" do
    dtm = DateTime.now()
    test_feature = @rally.create("portfolioitem/feature", {:Name => "test feature for rally api - #{dtm}"})
    desc = "adding description"
    update_fields = {:Description => "#{desc}"}
    upd = test_feature.update(update_fields)
    expect(upd["Description"]).to eq(desc)
  end

  #with the new DragandDropRank - this is going to be hard
  it "should rank relative to" do
    top_stories1 = @rally.find do |q|
      q.type = :story
      q.order = "Rank Asc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end

    story1 = top_stories1[0]
    story2 = top_stories1[1]

    story2.rank_above(story1)
    top_stories2 = @rally.find do |q|
      q.type = :story
      q.order = "Rank Asc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end

    st1_found = st2_found = false
    top_stories2.each do |story|
      st1_found = true if story.ObjectID == story1.ObjectID
      if story.ObjectID == story2.ObjectID
        st2_found = true
        break
      end
    end
    expect(st2_found).to eq(true)
    expect(st1_found).to eq(false)
    story2.rank_below(story1)

    top_stories3 = @rally.find do |q|
      q.type = :story
      q.order = "Rank Asc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end

    st1_found = st2_found = false
    top_stories3.each do |story|
      st2_found = true if story.ObjectID == story2.ObjectID
      if story.ObjectID == story1.ObjectID
        st1_found = true
        break
      end
    end
    expect(st1_found).to eq(true)
    expect(st2_found).to eq(false)
  end

  it "should rank to bottom and top" do
    @test_story.rank_to_top
    top_stories = @rally.find do |q|
      q.type = :story
      q.order = "Rank Asc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end
    top_story = top_stories[0]
    expect(top_story["ObjectID"]).to eq(@test_story["ObjectID"])

    @test_story.rank_to_bottom
    bottom_stories = @rally.find do |q|
      q.type = :story
      q.order = "Rank Desc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end
    bottom_story = bottom_stories[0]
    expect(bottom_story["ObjectID"]).to eq(@test_story["ObjectID"])
  end

  it "should do rank to with params on a plain update" do
    defect_hash = {}
    defect_hash["Severity"] = "Major Problem"
    params = {:rankTo => "BOTTOM"}
    updated_defect = @rally.update(:defect, @test_defect.ObjectID, defect_hash, params)
    expect(updated_defect.Severity).to eq("Major Problem")
    bottom_defects = @rally.find do |q|
      q.type = :defect
      q.order = "Rank Desc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end
    expect(bottom_defects[0]["ObjectID"]).to eq(@test_defect["ObjectID"])

    @test_defect.update({ "Notes"=>"Added notes"}, {:rankTo => "TOP"})
    top_defects = @rally.find do |q|
      q.type = :defect
      q.order = "Rank Asc"
      q.limit = 20
      q.page_size = 20
      q.fetch = "Name,Rank,ObjectID"
    end
    expect(top_defects[0]["ObjectID"]).to eq(@test_defect["ObjectID"])
  end

end
