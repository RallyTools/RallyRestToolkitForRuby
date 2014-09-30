

$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
$LOAD_PATH << File.expand_path('../../../examples',__FILE__)

ENV['PATH'] = "#{File.expand_path('../../../examples',__FILE__)}#{File::PATH_SEPARATOR}#{ENV['PATH']}"

# require 'aruba/cucumber'

require "rally_api"

