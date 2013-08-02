require 'spec_helper'

describe Event do
  context "validating" do
    let(:event) { build :event }
    subject { event }

    it { should require_presence_of(:name) }
    it { should require_presence_of(:opens_at) }
    it { should require_presence_of(:closes_at) }
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

  it "creates a list of field_fill" do
    ev = create(:ongoing_event)
    ev.field_fills.should be_empty
    ev.fields << (field = create(:field, event_id: ev.id, priority: 1))
    ev.fields << (field2 = create(:field, event_id: ev.id))
    ev.fields(true) # Forcing reload to check whether it's ordering by priority.
    ev.field_fills.count.should == 2
    ev.field_fills.first.field_id.should == field2.id
    ev.field_fills.last.field_id.should == field.id
  end
end
