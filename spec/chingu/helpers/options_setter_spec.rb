# frozen_string_literal: true

require "spec_helper"

class Car
  include Chingu::Helpers::OptionsSetter

  attr_accessor :angle, :speed
  attr_reader :color

  def initialize(params)
    set_options(params, { angle: 11, speed: 22 })
  end
end

describe Chingu::Helpers::OptionsSetter do
  context "using without defaults" do
    before do
      @car = Car.new(angle: 44)
    end

    it "sets angle from options" do
      expect(@car.angle).to eq(44)
    end

    it "sets speed from defaults" do
      expect(@car.speed).to eq(22)
    end

    it "handles attribute without writer" do
      expect(Car.new(color: :green).color).to eq(:green)
    end
  end
end
