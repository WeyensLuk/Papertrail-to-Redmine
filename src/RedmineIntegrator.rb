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

def truncate(string, max)
  string && string.length > max ? "#{string[0...max-3]}..." : string
end

def find_issue subject
  Issue.find(:all, :params => {:subject => subject}).elements.first
end

def parse_redmine_issue_subject_from_papertrail_message message
  truncate(message.split(';')[4], 250)
end

def generate_papertrail_more_info_link papertrail_event
  "for more info view: #{@papertrail_url}?center_on_id=#{papertrail_event[:id]}"
end

def create_redmine_issue papertrail_event
  issue = Issue.new subject: parse_redmine_issue_subject_from_papertrail_message(papertrail_event[:message]),
            project_id: @@papertrail_project.id,
            description: "#{papertrail_event[:message]}\n\n#{generate_papertrail_more_info_link(papertrail_event)}"
  
  if !issue.save then puts issue.errors.full_messages end
end

def update_redmine_issue_with_new_information issue, papertrail_event
  issue.description += "\n\nThis issue reoccured on #{papertrail_event[:display_received_at]}\n#{generate_papertrail_more_info_link(papertrail_event)}"
  if !issue.save then puts issue.errors.full_messages end
end

@@papertrail_project = get_papertrail_project
if !@@papertrail_project then @@papertrail_project = create_papertrail_project end

def log_redmine_issue papertrail_event, papertrail_url
  @papertrail_url = papertrail_url
  issue = find_issue(parse_redmine_issue_subject_from_papertrail_message(papertrail_event[:message]))
  if issue
    update_redmine_issue_with_new_information issue, papertrail_event
  else
    create_redmine_issue papertrail_event
  end
end