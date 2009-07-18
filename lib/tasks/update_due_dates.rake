namespace :issue_due_date_plugin do

  desc "Update due_dates of all Issues missing a due date to use their Version  or Deliverable due_date"
  task :update_due_dates => [:environment] do
    do_deliverable = Object.const_defined?("Deliverable")
    
    Issue.find(:all).each do |issue|
      before = issue.due_date

      # Use deliverable dates
      if do_deliverable
        
        if issue.due_date.nil? && issue.set_due_date_from_deliverable
          if issue.save
            issue.reload
            puts "Changed issue due date from #{before.to_s} to #{issue.due_date} for issue ##{issue.id}"
          else
            puts "Error on issue ##{issue.id}: #{issue.errors.full_messages}"
          end
        end
        
      end
      
      # Use version dates
      if issue.due_date.nil? && issue.set_due_date_from_version
        if issue.save
          issue.reload
          puts "Changed issue due date from #{before.to_s} to #{issue.due_date} for issue ##{issue.id}"
        else
          puts "Error on issue ##{issue.id}: #{issue.errors.full_messages}"
        end
      end

    end
    
  end

end
