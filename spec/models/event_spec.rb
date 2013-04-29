require 'spec_helper'

describe Event do
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

  it "validates closes_at is after opens_at" do
    (build(:event) { |e| e.closes_at = e.opens_at - 1.day }).should have(1).
        errors_on(:closes_at)
  end

  it "validates presence of name" do
    build(:event, name: "").should have(1).errors_on(:name)
  end

  it "validates presence of opens_at" do
    build(:event, opens_at: "").should have(1).errors_on(:opens_at)
  end

  it "validates presence of closes_at" do
    build(:event, closes_at: "").should have(1).errors_on(:closes_at)
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
end