require_relative "rally_api_spec_helper"

describe "Rally Authentication" do
#TODO: Use RSpec configuration (in spec helper) to only run tests if
#      config_file is present, and config file includes an API key,
#      username, and password
  let(:config_file)      { "RallyAPIcredentials_PROD.txt" }
  let(:rally_config)     { load_api_config(config_file).test_setup }
  let(:rally_connection) { RallyAPI::RallyRestJson.new(rally_config) }
  let(:first_defect)     { retrieve_first_defect(rally_connection) }


  context "API Key, Username, and Password are valid and present" do
    it "can retrieve defects" do      
      (first_defect[:name]).should_not be_empty
      (first_defect[:type]).should eq 'Defect'
    end
  end

  context "No API key, valid username and password" do
    it "can retrieve defects" do
      rally_config.delete(:api_key)

      (first_defect[:name]).should_not be_empty
      (first_defect[:type]).should eq 'Defect'
    end  
  end

  context "No API key, invalid username or password" do
    it "should throw a reasonable exception for a bad password or username" do
      rally_config.delete(:api_key)
      rally_config[:password] = "asdf"

      lambda{RallyAPI::RallyRestJson.new(rally_config)}.should raise_error(StandardError, /RallyAPI - HTTP-401/)
    end
  end


  context "Invalid API key, valid username or password" do
    it "should throw a reasonable exception for a bad password or username" do
      rally_config[:api_key] = "bad_api_key"

      lambda{RallyAPI::RallyRestJson.new(rally_config)}.should raise_error(StandardError, /RallyAPI - HTTP-401/)
    end
  end

  context "Valid API Key is present and username is invalid" do
    it "should ignore a bad username" do
      rally_config[:username] = "asdf"

      (first_defect[:name]).should_not be_empty
      (first_defect[:type]).should eq 'Defect'
    end
  end

  context "API Key is present and password is invalid" do    
    it "should ignore a bad username if the API key is present" do
      rally_config[:password] = "asdf"

      (first_defect[:name]).should_not be_empty
      (first_defect[:type]).should eq 'Defect'
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