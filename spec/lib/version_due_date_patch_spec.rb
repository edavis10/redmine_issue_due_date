require File.dirname(__FILE__) + '/../spec_helper'

describe Version, '#before_save' do
  it 'should call #update_issue_due_dates' do
    Version.before_save.collect(&:method).should include(:update_issue_due_dates)
  end
end

describe Version, '#update_issue_due_dates' do
  before(:each) do
    future = 3.days.since
    soon = 1.day.since
    @version = Version.new(:effective_date => soon)
    @issue_with_due_date_matching = mock_model(Issue,
                                               :due_date => @version.due_date,
                                               :version => @version,
                                               :due_date_set_by_version? => true,
                                               :update_attribute => true)

    @issue_with_other_due_date = mock_model(Issue,
                                            :due_date => 3.days.since,
                                            :version => @version,
                                            :due_date_set_by_version? => false,
                                            :update_attribute => true)

    @issue_without_due_date =  mock_model(Issue,
                                          :due_date => nil,
                                          :version => @version,
                                          :due_date_set_by_version? => false,
                                          :update_attribute => true)

    @version.stub!(:fixed_issues).and_return([@issue_with_due_date_matching, @issue_with_other_due_date, @issue_without_due_date])
  end
  
  it 'should update all issues without a due date to the Version due_date' do
    @issue_without_due_date.should_receive(:update_attribute).with(:due_date, @version.due_date)
    @version.update_issue_due_dates
  end

  it "should update all issues with due_dates matching the old version to the new due_date" do
    @issue_with_due_date_matching.should_receive(:update_attribute).with(:due_date, @version.due_date)
    @version.update_issue_due_dates
  end

  it "should not update issues with due_dates different than the new or old version's due date" do
    @issue_with_other_due_date.should_not_receive(:update_attribute)
    @version.update_issue_due_dates
  end
end
