require 'redmine'

Redmine::Plugin.register :redmine_issue_due_date do
  name 'Issue Due Date'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-misc'
  author 'Eric Davis of Little Stream Software'
  author_url 'http://www.littlestreamsoftware.com'
  
  description 'Plugin to set the issue due_date based on Version and / or Deliverable due dates'
  version '0.1.0'
  requires_redmine :version_or_higher => '0.8.0'
end

require_dependency 'issue_due_date_patch'
Issue.send(:include, IssueDueDatePatch)

require_dependency 'version_due_date_patch'
Version.send(:include, VersionDueDatePatch)

if Object.const_defined?("Deliverable")
  require_dependency 'deliverable_due_patch'
  Deliverable.send(:include, DeliverableDuePatch)
end
