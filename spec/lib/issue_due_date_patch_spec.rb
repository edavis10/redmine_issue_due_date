require File.dirname(__FILE__) + '/../spec_helper'

describe Issue, '#before_save' do
  it 'should call #update_due_date' do
    Issue.before_save.collect(&:method).should include(:update_due_date)
  end
end

describe Issue, '#update_due_date' do

end

describe Issue, '#set_due_date_from_version' do

end

describe Issue, '#set_due_date_from_deliverable' do

end

describe Issue, '#due_date_set_by_version?' do

end

describe Issue, '#due_date_set_by_deliverable?' do

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
