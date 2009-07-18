require_dependency 'issue'

module IssueDueDate
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        before_save :update_due_date
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
      
      # Aliased to +before_save+ when included.  This will update the issue's due_date like so
      # 
      # Precondition: due_date is empty
      #
      # * Use the Version due date or
      # * Use the Deliverable due date
      #
      # Precondition: due_date has a version or deliverable due_date already and the Version or
      #               Deliverable is changing.
      #
      # * Use the new Version due date or
      # * Use the new Deliverable due date
      #
      def update_due_date
        
        if self.due_date.blank?
          # Doesn't have a due date already
          unless self.set_due_date_from_version
            # Try Deliverable
            set_due_date_from_deliverable
          end

        else
          if self.due_date_set_by_version? 
            # If the due date is set by the version then update the due_date to the current version
            self.due_date = self.fixed_version.due_date unless self.fixed_version.nil?
          elsif self.due_date_set_by_deliverable?
            # If the due date is set by the deliverable then update the due_date to the current deliverable
            self.due_date = self.deliverable.due unless self.deliverable.nil?
          end
        end

        return true
      end

      # Set the +due_date+ based on the version's due_date
      def set_due_date_from_version
        unless self.fixed_version.blank? || self.fixed_version.due_date.blank? || self.due_date == self.fixed_version.due_date
          self.due_date = self.fixed_version.due_date
          return true
        else
          return false
        end
      end

      # Set the +due_date+ based on the deliverable's due_date
      def set_due_date_from_deliverable
        return false unless deliverable_defined?
        
        unless self.deliverable.blank? || self.deliverable.due.blank? || self.due_date == self.deliverable.due
          self.due_date = self.deliverable.due
          return true
        else
          return false
        end      
      end

      # Is the issue's +due_date+ the same as it's old version?
      def due_date_set_by_version?
        orig_issue = Issue.find_by_id(self.id) || Issue.new
        orig_date = orig_issue.fixed_version.due_date unless orig_issue.fixed_version.nil?
        orig_date ||= nil
        
        return orig_date == self.due_date
      end
      
      # Is the issue's +due_date+ the same as it's old deliverable?
      def due_date_set_by_deliverable?
        return false unless deliverable_defined?

        orig_issue = Issue.find_by_id(self.id) || Issue.new
        return false unless orig_issue.deliverable

        orig_date = orig_issue.deliverable.due
        orig_date ||= nil
        
        return orig_date == self.due_date
      end
      
      # Wrapper to check for the +Deliverable+ class
      def deliverable_defined?
        return Object.const_defined?("Deliverable")
      end
    end    
  end
end
