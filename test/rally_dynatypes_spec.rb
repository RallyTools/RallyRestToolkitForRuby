require "rspec"
require_relative "rally_api_spec_helper"

describe "DynaType and Portfolio Item specific tests" do

  before :all do
    @rally = RallyAPI::RallyRestJson.new(RallyAPISpecHelper::TEST_SETUP)
  end

  #1-------------------------------------------------------------------------------------------
  it "should be able to create a PI post 1.37" do
    pi_types = @rally.find do |q|
      q.type = :typedefinition
      q.query_string = '(Parent.Name = "Portfolio Item")'
      q.limit = 10
      q.fetch = "ElementName,TypePath"
    end

    name_to_try = nil
    pi_types.each do |typ|
      next if typ.ElementName == "PortfolioItem"
      name_to_try = typ.TypePath
    end

    fields = {:Name => "test #{name_to_try} for rally_api - #{DateTime.now}"}
    new_pi = @rally.create(name_to_try.downcase.gsub(" ", "").to_sym, fields)
    new_pi.should_not be_nil
    new_pi.Name.should == fields[:Name]
  end

  #2-------------------------------------------------------------------------------------------
  it "should be able to interact with PIs 1.37" do
    pi_types = @rally.find do |q|
      q.type = :typedefinition
      q.query_string = '(Parent.Name = "Portfolio Item")'
      q.limit = 10
      q.fetch = "ElementName,TypePath"
    end

    name_to_try = nil
    pi_types.each do |typ|
      next if typ.ElementName == "PortfolioItem"
      name_to_try = typ.TypePath
    end

    type_to_try = name_to_try.downcase.gsub(" ", "").to_sym
    fields = {:Name => "test #{name_to_try} for rally_api - #{DateTime.now}"}
    new_pi = @rally.create(type_to_try, fields)
    new_pi.should_not be_nil
    new_pi.Name.should == fields[:Name]

    pi = @rally.read(type_to_try, new_pi["ObjectID"])
    pi.should_not be_nil
    pi["Name"].should == fields[:Name]

    pi_list = @rally.find do |q|
      q.type = type_to_try
      q.limit = 1000
      q.order = "CreationDate Desc"
      q.fetch = "Name"
    end

    found = false
    pi_list.each do |pi|
      found = true if pi.Name == fields[:Name] && pi.ObjectID == new_pi.ObjecID
    end
    found.should == true

    fields = @rally.get_fields_for(type_to_try)
    fields.should_not be_nil
  end

  #3-------------------------------------------------------------------------------------------
  it "should be able to create a custom PI in a non default workspace" do
    custom_pi_type = "portfolioitem/" << RallyAPISpecHelper::EXTRA_SETUP[:custom_pi_type]
    non_default_ws = @rally.find_workspace(RallyAPISpecHelper::EXTRA_SETUP[:nondefault_ws])

    fields = {:Name => "test #{custom_pi_type} for rally_api - #{DateTime.now}", "Workspace" => non_default_ws}
    new_pi = @rally.create(custom_pi_type, fields)
    new_pi.should_not be_nil
    new_pi["Workspace"].ref.should == non_default_ws.ref
  end

end