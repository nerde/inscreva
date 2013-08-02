require 'spec_helper'

describe Wiki do
  context 'validating' do
    let(:wiki) { build(:wiki) }
    subject { wiki }

    it { should require_presence_of :name }
    it { should require_presence_of :event }
    it { should require_presence_of :title }

    it "should validate uniqueness of name within the event" do
      should have(0).errors_on(:name)
      wiki2 = create(:wiki, name: wiki.name)
      should have(0).errors_on(:name)
      wiki2.update_attributes event_id: wiki.event_id
      should have(1).errors_on(:name)
    end
  end
end