begin
  require 'deliverable' unless Object.const_defined?("Deliverable")

  if Object.const_defined?("Deliverable")
    module IssueDueDate
      module DeliverablePatch
        def self.included(base)
          base.extend(ClassMethods)

          base.send(:include, InstanceMethods)

          # Same as typing in the class 
          base.class_eval do
            unloadable # Send unloadable so it will not be unloaded in development
            
            before_save :update_issue_due_dates
            
          end
        end
        
        module ClassMethods
        end
        
        module InstanceMethods
          
          # Added as a +before_save+ to push out the updated due_date to the issues
          def update_issue_due_dates
            self.issues.each do |issue|
              if issue.due_date.blank? || issue.due_date_set_by_deliverable?
                issue.update_attribute(:due_date, self.due)
              end
            end
          end
          
        end    
      end
    end
  end
rescue LoadError
  # Skip
end
