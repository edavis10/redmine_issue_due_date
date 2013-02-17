require_dependency 'issue'

module IssueDueDate
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        before_save :update_due_date
      end
    end
    
    module InstanceMethods
      # Updates the due date by checking the due_date set on the
      # assigned Version or Deliverable
      def update_due_date
        if deliverable_defined? && (due_date.blank? || due_date_set_by_deliverable?)
          set_due_date_from_deliverable
        elsif due_date.blank? && due_date_set_by_version?
          set_due_date_from_version
        elsif due_date.blank? && due_date_set_by_project?
          set_due_date_from_project
        end

        return true
      end

      # Set the +due_date+ based on the version's due_date
      def set_due_date_from_version
        if fixed_version && fixed_version.due_date != due_date
          self.due_date = self.fixed_version.due_date
          return true
        else
          return false
        end
      end

      # Set the +due_date+ based on the projects due_date default
      def set_due_date_from_project
        self.due_date = (Time.now + self.project.default_days_due.to_i.days).change(:sec => 0).change(:min => 0).change(:hour => 0)
        return true
      end

      # Set the +due_date+ based on the deliverable's due_date
      def set_due_date_from_deliverable
        if (deliverable_defined? && deliverable && deliverable.due != due_date)
          self.due_date = self.deliverable.due
          return true
        else
          return false
        end      
      end

      # Is the issue's +due_date+ the same as it's old version?
      def due_date_set_by_version?
        orig_issue = Issue.find_by_id(self.id)

        return !!(orig_issue &&
                  orig_issue.fixed_version &&
                  orig_issue.fixed_version.due_date == self.due_date)
      end
      
      # Is the issue's +due_date+ defined by project settings?
      def due_date_set_by_project?
        return false if project.default_days_due.nil?
        return true
      end


      # Is the issue's +due_date+ the same as it's old deliverable?
      def due_date_set_by_deliverable?
        orig_issue = Issue.find_by_id(self.id)

        return !!(deliverable_defined? &&
                  orig_issue &&
                  orig_issue.deliverable &&
                  orig_issue.deliverable.respond_to?(:due) &&
                  orig_issue.deliverable.due == self.due_date)
      end
      
      # Wrapper to check for the +Deliverable+ class
      def deliverable_defined?
        return Object.const_defined?("Deliverable")
      end
    end    
  end
end
