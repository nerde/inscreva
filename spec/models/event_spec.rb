require 'spec_helper'

describe Event do
  context "validating" do
    let(:event) { build :event, opens_at: Time.now }
    subject { event }

    it { should require_presence_of(:name) }
    it { should require_presence_of(:identifier) }
    it { should require_uniqueness_of(:identifier, used_value: create(:event).identifier) }
    it { should require_valid(:closes_at, invalid: event.opens_at - 1.day,
        valid: event.opens_at + 1.day) }
  end

  it "is ongoing when now is between opens_at and closes_at" do
    build(:ongoing_event).ongoing?.should be_true
  end

  it "is not ongoing by default" do
    Event.new.ongoing?.should be_false
  end

  it "is not ongoing when closes_at is in the past" do
    build(:past_event).ongoing?.should be_false
  end

  it "is not ongoing when opens_at is in the future" do
    build(:future_event).ongoing?.should be_false
  end

  it "is not ongoing when opens_at or closes_at are null" do
    build(:ongoing_event, opens_at: nil).ongoing?.should be_false
    build(:ongoing_event, closes_at: nil).ongoing?.should be_false
    build(:ongoing_event, opens_at: nil, closes_at: nil).ongoing?.should be_false
  end

  it "scopes ongoing events" do
    curr = create(:ongoing_event)
    past = create(:past_event)
    future = create(:future_event)
    events = Event.ongoing
    events.include?(curr).should be_true
    events.include?(past).should be_false
    events.include?(future).should be_false
  end

  it "scopes future events" do
    curr = create(:ongoing_event)
    past = create(:past_event)
    future = create(:future_event)
    events = Event.future
    events.include?(curr).should be_false
    events.include?(past).should be_false
    events.include?(future).should be_true
  end

  it 'copies fields from another event' do
    f1 = create(:field, name: 'Field 1')
    f2 = create(:field, name: 'Field 2', event_id: f1.event_id, extra: '1=A',
        group_name: 'Testtt', allowed_file_extensions: ['pdf'], max_file_size: 1,
        hint: 'Hintt')
    e1 = f1.event

    e2 = create(:event)
    e2.copy_fields_from e1
    e2.fields.size.should == 2
    e2.fields[0].name.should == f1.name
    e2.fields[1].name.should == f2.name
    e2.fields[1].extra.should == f2.extra
    e2.fields[1].group_name.should == f2.group_name
    e2.fields[1].allowed_file_extensions.should == f2.allowed_file_extensions
    e2.fields[1].max_file_size.should == f2.max_file_size
    e2.fields[1].hint.should == f2.hint

    e2.fields[0].priority.should == 1
    e2.fields[1].priority.should == 2

    e2.fields << Field.new(name: "Another One", priority: 3)
    e2.copy_fields_from e1
    e2.fields.size.should == 5
    e2.fields[3].name.should == f1.name
    e2.fields[4].name.should == f2.name
    e2.fields[3].priority.should == 4
    e2.fields[4].priority.should == 5

    e2.save.should be_true
    e2.fields[4].should_not be_new_record
  end

  describe "for_main_page" do
    let(:past_event)          { create(:past_event,    published: true) }
    let(:ongoing_event)       { create(:ongoing_event, published: true) }
    let(:not_published_event) { create(:ongoing_event, published: false) }
    let(:future_event)        { create(:future_event,  published: true) }

    subject { Event.for_main_page }

    before(:each) do
      past_event
      ongoing_event
      not_published_event
      future_event
    end

    it {
      should     include(ongoing_event)
      should     include(future_event)
      should_not include(past_event)
      should_not include(not_published_event)
    }
  end
end
