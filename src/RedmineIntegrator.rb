require 'active_resource'
require 'yaml'
require 'pry'

CONFIG = YAML.load_file('../config/redmine.yml') unless defined? CONFIG

class Issue < ActiveResource::Base
  self.site = CONFIG['site']
  self.user = CONFIG['user']
  self.password = CONFIG['password']
end

issue = Issue.find(1)
binding.pry
puts issue.description

def CreateRedmineIssue papertrail_event
    puts 'Issue created'
end
