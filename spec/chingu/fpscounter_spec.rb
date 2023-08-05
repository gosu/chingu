# frozen_string_literal: true

require "spec_helper"

describe Chingu::FPSCounter do
  it { is_expected.to respond_to(:fps) }
  it { is_expected.to respond_to(:milliseconds_since_last_tick) }
  it { is_expected.to respond_to(:ticks) }

  describe "#register_tick" do
    before do
      allow(Gosu).to receive(:milliseconds).and_return(1000)

      subject { FPSCounter.new }
    end

    it "increases the tick counter" do
      expect do
        subject.register_tick
      end.to change(subject, :ticks).from(0).to(1)
    end

    it "keeps track of the fps" do
      # #register_tick has been called 3 times within 1 second = 3 FPS
      expect do
        subject.register_tick

        allow(Gosu).to receive(:milliseconds).and_return(1500)

        subject.register_tick

        allow(Gosu).to receive(:milliseconds).and_return(2000)

        subject.register_tick
      end.to change(subject, :fps).from(0).to(3)
    end

    it "calculates how many milliseconds passed since last game loop" \
       "iteration and returns that value" do
      allow(Gosu).to receive(:milliseconds).and_return(2000)

      expect(subject.register_tick).to eq(1000)
      expect(subject.milliseconds_since_last_tick).to eql(1000)
    end
  end
end
