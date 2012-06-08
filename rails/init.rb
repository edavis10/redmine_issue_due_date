require 'redmine'

require_dependency 'issue_due_date_patch'
require_dependency 'version_due_date_patch'
require_dependency 'deliverable_due_patch'

Redmine::Plugin.register :redmine_issue_due_date do
  name 'Issue Due Date'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-misc'
  author 'Eric Davis of Little Stream Software'
  author_url 'http://www.littlestreamsoftware.com'
  
  description 'Plugin to set the issue due_date based on Version and / or Deliverable due dates'
  version '0.2.0'
  requires_redmine :version_or_higher => '0.8.0'
end
