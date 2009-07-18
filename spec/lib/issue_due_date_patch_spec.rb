require File.dirname(__FILE__) + '/../spec_helper'

describe Issue, '#before_save' do
  it 'should call #update_due_date' do
    Issue.before_save.collect(&:method).should include(:update_due_date)
  end
end

describe Issue, '#update_due_date' do
  before(:each) do
    @issue = Issue.new
    @issue.stub!(:deliverable_defined?).and_return(true)
  end
  
  describe "for an issue without a due date" do
    it 'and no deliverable should try to set the due_date from the version' do
      @issue.stub!(:deliverable_defined?).and_return(false)
      @issue.should_receive(:set_due_date_from_version)
      @issue.update_due_date
    end

    it 'should try to set the due_date from the deliverable' do
      @issue.should_receive(:set_due_date_from_deliverable)
      @issue.update_due_date
    end

  end

  describe "for an issue with a due date that is the same as the version" do
    it 'should update the due_date from the version' do
      @issue.due_date = Date.today
      @issue.should_receive(:due_date_set_by_version?).and_return(true)
      @issue.should_receive(:set_due_date_from_version)
      @issue.update_due_date
    end

  end

  describe "for an issue with a due date that is the same as the deliverable" do
    it 'should update the due_date from the deliverable' do
      @issue.due_date = Date.today
      @issue.should_receive(:due_date_set_by_deliverable?).and_return(true)
      @issue.should_receive(:set_due_date_from_deliverable)
      @issue.update_due_date
    end

  end

  describe "for an issue with a due date different from the version or deliverable" do
    it 'should not change the due_date' do
      @issue.due_date = Date.today
      @issue.should_receive(:due_date_set_by_version?).and_return(false)
      @issue.should_receive(:due_date_set_by_deliverable?).and_return(false)
      @issue.should_not_receive(:set_due_date_from_version)
      @issue.should_not_receive(:set_due_date_from_deliverable)
      @issue.update_due_date
    end

  end
end

describe Issue, '#set_due_date_from_version' do
  before(:each) do
    @issue = Issue.new(:id => 1000)
  end

  it 'should do nothing if the issue has no version' do
    @issue.should_not_receive(:due_date=)
    @issue.stub!(:fixed_version).and_return(nil)
    @issue.set_due_date_from_version
  end

  it "should do nothing if the issue's version has no due date" do
    @issue.should_not_receive(:due_date=)
    @issue.stub!(:fixed_version).and_return(mock('version', :due_date => nil))
    @issue.set_due_date_from_version
  end

  it "should do nothing if the issue's version has the same due date" do
    today = Date.today
    @issue.due_date = today
    @issue.should_not_receive(:due_date=)
    @issue.stub!(:fixed_version).and_return(mock('version', :due_date => today))
    @issue.set_due_date_from_version
  end

  it "should set the due date of the issue to the version's if they differ" do
    today = Date.today
    yesterday = Date.yesterday
    @issue.due_date = yesterday
    @issue.should_receive(:due_date=).with(today)
    @issue.stub!(:fixed_version).and_return(mock('version', :due_date => today))
    @issue.set_due_date_from_version
  end
end

describe Issue, '#set_due_date_from_deliverable' do
  before(:each) do
    @issue = Issue.new(:id => 1000)
    @issue.stub!(:deliverable_defined?).and_return(true)
  end
  
  it 'should do nothing if deliverable is not defined' do
    @issue.should_not_receive(:due_date=)
    @issue.should_receive(:deliverable_defined?).and_return(false)
    @issue.set_due_date_from_deliverable
  end

  it 'should do nothing if the issue has no deliverable' do
    @issue.should_not_receive(:due_date=)
    @issue.stub!(:deliverable).and_return(nil)
    @issue.set_due_date_from_deliverable
  end

  it "should do nothing if the issue's deliverable has no due date" do
    @issue.should_not_receive(:due_date=)
    @issue.stub!(:deliverable).and_return(mock('deliverable', :due => nil))
    @issue.set_due_date_from_deliverable
  end

  it "should do nothing if the issue's deliverable has the same due date" do
    today = Date.today
    @issue.due_date = today
    @issue.should_not_receive(:due_date=)
    @issue.stub!(:deliverable).and_return(mock('deliverable', :due => today))
    @issue.set_due_date_from_deliverable
  end

  it "should set the due date of the issue to the deliverable's if they differ" do
    today = Date.today
    yesterday = Date.yesterday
    @issue.due_date = yesterday
    @issue.should_receive(:due_date=).with(today)
    @issue.stub!(:deliverable).and_return(mock('deliverable', :due => today))
    @issue.set_due_date_from_deliverable
  end

end

describe Issue, '#due_date_set_by_version?' do
  before(:each) do
    @one_day = 1.day.since
    @today = Date.today

    @issue = Issue.new(:id => 1000)
    Issue.stub!(:find_by_id).with(@issue.id).and_return(@issue)
  end

  describe 'with a version' do
    before(:each) do
      @version = mock_model(Version)
      @issue.stub!(:fixed_version).and_return(@version)
    end
    
    it 'should get the version due_date' do
      @version.should_receive(:due_date).and_return(1.day.since)
      @issue.due_date_set_by_version?
    end

    it 'should be true if the version due_date matches the issue due_date' do
      @version.should_receive(:due_date).and_return(@today)
      @issue.should_receive(:due_date).and_return(@today)
      @issue.due_date_set_by_version?.should be_true
    end

    it 'should be false if the version due_date matches the issue due_date' do
      @version.should_receive(:due_date).and_return(@one_day)
      @issue.should_receive(:due_date).and_return(@today)
      @issue.due_date_set_by_version?.should be_false
    end

  end

  describe 'without a version' do
    it 'should be false' do
      @issue.stub!(:fixed_version).and_return(nil)
      @issue.due_date_set_by_version?.should be_false
    end
  end
end

describe Issue, '#due_date_set_by_deliverable?' do
  before(:each) do
    @one_day = 1.day.since
    @today = Date.today

    @issue = Issue.new(:id => 1000)
    @issue.stub!(:deliverable_defined?).and_return(true)
    Issue.stub!(:find_by_id).with(@issue.id).and_return(@issue)
  end

  describe 'with a deliverable' do
    before(:each) do
      @deliverable = mock('deliverable')
      @issue.stub!(:deliverable).and_return(@deliverable)
    end
    
    it 'should get the deliverable due_date' do
      @deliverable.should_receive(:due).and_return(1.day.since)
      @issue.due_date_set_by_deliverable?
    end

    it 'should be true if the delieverable due_date matches the issue due_date' do
      @deliverable.should_receive(:due).and_return(@today)
      @issue.should_receive(:due_date).and_return(@today)
      @issue.due_date_set_by_deliverable?.should be_true
    end

    it 'should be false if the delieverable due_date matches the issue due_date' do
      @deliverable.should_receive(:due).and_return(@one_day)
      @issue.should_receive(:due_date).and_return(@today)
      @issue.due_date_set_by_deliverable?.should be_false
    end

  end

  describe 'without a deliverable' do
    it 'should be false' do
      @issue.stub!(:deliverable).and_return(nil)
      @issue.due_date_set_by_deliverable?.should be_false
    end
  end
end

describe Issue, '#deliverable_defined?' do
  it 'should be true if Deliverable is defined (Model class)' do
    Object.should_receive(:const_defined?).with('Deliverable').and_return(true)
    Issue.new.deliverable_defined?.should be_true
  end

  it 'should be false if Deliverable is not defined' do
    Object.should_receive(:const_defined?).with('Deliverable').and_return(false)
    Issue.new.deliverable_defined?.should be_false
  end
end
