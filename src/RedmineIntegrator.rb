require 'active_resource'
require 'yaml'

CONFIG = YAML.load_file(Dir.pwd + '/config/redmine.yml') unless defined? CONFIG

class RedmineResource < ActiveResource::Base
  self.site = CONFIG['site']
  self.user = CONFIG['user']
  self.password = CONFIG['password']
  self.include_root_in_json = true
end

class IssueCollection < ActiveResource::Collection
  def initialize(parsed = {})
    @elements = parsed['issues']
  end
end

class Issue < RedmineResource
  self.collection_parser = IssueCollection
end

class ProjectCollection < ActiveResource::Collection
  def initialize(parsed = {})
    @elements = parsed['projects']
  end
end

class Project < RedmineResource
  self.collection_parser = ProjectCollection
end

def create_papertrail_project
  project = Project.new  name: 'Papertrail', 
                  identifier: 'papertrail', 
                  description: 'This is an automatically generated project to log Redmine issues that originate in Papertrail',
                  enabled_module_names: ['issue_tracking']

  if !project.save then puts project.errors.full_messages end
  project
end

def get_papertrail_project
  #WHY? Redmine API does not support parameters for filtering on name on the Projects API, so search in the array of all projects manually
  projects = Project.find(:all, :params => {:name => 'Papertrail'})
  projects.elements.first{|project| project.name == 'Papertrail'}
end

papertrail_project = get_papertrail_project
if !papertrail_project then papertrail_project = create_papertrail_project end

def create_redmine_issue papertrail_event
    puts 'Issue created'
end
