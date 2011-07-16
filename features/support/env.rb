require 'rubygems'
require 'rake'
require 'bundler'

Bundler.require :default, :development

$:.unshift File.dirname(__FILE__) + '/../../lib'
$:.unshift File.dirname(__FILE__) + 'models'

require 'jo'
require 'active_record'

ActiveRecord::Base.establish_connection YAML.load(open(File.join('features', 'support', 'config', 'database.yml')))

FileList[File.join(File.dirname(__FILE__), 'models', '*.rb')].each do |file|
  require file
end