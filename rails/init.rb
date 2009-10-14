require 'redmine'

require 'issue_due_date_patch'
require 'version_due_date_patch'
require 'deliverable_due_patch'

require 'dispatcher'
Dispatcher.to_prepare do
  Issue.send(:include, IssueDueDate::IssuePatch)
  Version.send(:include, IssueDueDate::VersionPatch)
  Deliverable.send(:include, IssueDueDate::DeliverablePatch) if Object.const_defined?("Deliverable")
end


Redmine::Plugin.register :redmine_issue_due_date do
  name 'Issue Due Date'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-misc'
  author 'Eric Davis of Little Stream Software'
  author_url 'http://www.littlestreamsoftware.com'
  
  description 'Plugin to set the issue due_date based on Version and / or Deliverable due dates'
  version '0.1.0'
  requires_redmine :version_or_higher => '0.8.0'
end
