require_relative "spec_helper"

describe "Rally API Key Auth" do
#TODO: Use RSpec configuration (in spec helper) to only run tests if
#      config_file is present, and config file includes an API key,
#      username, and password

  let(:config_file)      { "APIconfig_rally1.txt" }
  let(:rally_config)     { load_api_config(config_file) }
  let(:rally_connection) { RallyAPI::RallyRestJson.new(rally_config) }
  let(:first_defect)     { retrieve_first_defect(rally_connection) }

  context "Valid API Key" do
    it "can retrieve defects with valid username and password" do      
      expect(first_defect[:name]).not_to be_empty
      expect(first_defect[:type]).to eq 'Defect'
    end

    it "can retrieve defects without username or password" do
      rally_config.delete(:username)
      rally_config.delete(:password)

      expect(first_defect[:name]).not_to be_empty
      expect(first_defect[:type]).to eq 'Defect'
    end
  
    it "can retrieve defects with invalid username" do
      rally_config[:username] = "asdf"

      expect(first_defect[:name]).not_to be_empty
      expect(first_defect[:type]).to eq 'Defect'
    end
   
    it "can retrieve defects with invalid password" do
      rally_config[:password] = "asdf"

      expect(first_defect[:name]).not_to be_empty
      expect(first_defect[:type]).to eq 'Defect'
    end
  end

  context "No API key" do
    it "can retrieve defects with valid username and password" do
      rally_config.delete(:api_key)

      expect(first_defect[:name]).not_to be_empty
      expect(first_defect[:type]).to eq 'Defect'
    end  

    it "should throw a reasonable exception with invalid password" do
      rally_config.delete(:api_key)
      rally_config[:password] = "asdf"

      expect{RallyAPI::RallyRestJson.new(rally_config)}.to raise_error(StandardError, /RallyAPI - HTTP-401/)
    end
  end

  context "Invalid API key, valid username or password" do
    it "should throw a reasonable exception" do
      rally_config[:api_key] = "bad_api_key"

      expect{RallyAPI::RallyRestJson.new(rally_config)}.to raise_error(StandardError, /RallyAPI - HTTP-401/)
    end
  end
end

# TODO: Move into shared RSpec helpers folder
def retrieve_first_defect(api_connection)
  defect_query = RallyAPI::RallyQuery.new(
    type: "defect",
    fetch: "FormattedID, Name,CreationDate",
    limit: 10,
    page_size: 10,
    project_scope_up: false,
    project_scope_down: true,
    order: "CreationDate Desc" )
  results = api_connection.find(defect_query)

  first_defect = { name: results[0].name,
                   type: results[0].type,
                   formatted_id: results[0].rally_object['FormattedID'] }
end