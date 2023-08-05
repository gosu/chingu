# frozen_string_literal: true

require "spec_helper"

describe Chingu::Inflector do
  describe "#camelize" do
    it "camelizes strings" do
      expect(subject.camelize("automatic_assets")).to eql("AutomaticAssets")
    end
  end

  describe "#underscore" do
    it "converts class-like strings to underscore" do
      expect(subject.underscore("FireBall")).to eql("fire_ball")
    end
  end
end
