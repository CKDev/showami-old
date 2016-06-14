require "rails_helper"

describe ApplicationHelper do
  describe "#devise_mapping" do
    it "returns the devise mappings" do
      expect(helper.devise_mapping).to be_an_instance_of(Devise::Mapping)
    end
  end
end
