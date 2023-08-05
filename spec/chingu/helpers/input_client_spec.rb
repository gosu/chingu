# frozen_string_literal: true

require "spec_helper"

describe Chingu::Helpers::InputClient do
  before do
    $window = double(Gosu::Window)
    allow($window).to receive(:button_down?) { false }

    @subject = Object.new.extend described_class
    allow(@subject).to receive(:handler1) { nil }

    @handler1 = @subject.method :handler1
    allow(@subject).to receive(:handler2) { nil }

    @handler2 = @subject.method :handler2
    allow(@subject).to receive(:handler2)
  end

  after do
    $window = nil
  end

  # TODO: Make more consistent

  describe "#holding?" do
    it "is true if that key is being held down" do
      expect($window).to receive(:button_down?).with(Gosu::KbSpace)
                                               .and_return(true)

      expect(@subject.holding?(:space)).to be_truthy
    end

    it "is false if that key is being held down" do
      expect($window).to receive(:button_down?).with(Gosu::KbSpace)
                                               .and_return(false)

      expect(@subject.holding?(:space)).to be_falsy
    end
  end

  describe "#holding_all?" do
    it "is true if all of those keys are being held down" do
      expect($window).to receive(:button_down?).with(Gosu::KbSpace)
                                               .and_return(true)
      expect($window).to receive(:button_down?).with(Gosu::KbA)
                                               .and_return(true)

      expect(@subject.holding_all?(:space, :a)).to be_truthy
    end

    it "is false if all of those keys are not being held down" do
      expect(@subject.holding_all?(:space, :a)).to be_falsy
    end

    it "is false if some of those keys are not being held down" do
      expect($window).to receive(:button_down?).with(Gosu::KbSpace)
                                               .and_return(true)

      expect(@subject.holding_all?(:space, :a)).to be_falsy
    end
  end

  describe "#holding_any?" do
    it "is true if any of those keys are being held down" do
      allow($window).to receive(:button_down?).with(Gosu::KbA)
                                              .and_return(true)
      allow($window).to receive(:button_down?).with(Gosu::KbSpace)
                                              .and_return(true)

      expect(@subject.holding_any?(:space, :a)).to be_truthy
    end

    it "is false if none of those keys are being held down" do
      expect(@subject.holding_any?(:space, :a)).to be_falsy
    end
  end

  describe "#input" do
    it "is an empty hash initially" do
      expect(@subject.input).to eq({})
    end
  end

  describe "#input=" do
    it "sets the input hash" do
      @subject.input = { a: Chingu::GameStates::Pause, b: Chingu::GameState }

      expect(@subject.input).to eq({ a: [Chingu::GameStates::Pause],
                                     b: [Chingu::GameState] })
    end

    it "sets the input array" do
      allow(@subject).to receive(:a)
      allow(@subject).to receive(:b)

      @subject.input = %i[a b]
      expect(@subject.input).to eq({ a: [@subject.method(:a)],
                                     b: [@subject.method(:b)] })
    end
  end

  describe "#add_inputs" do
    it "sets the input hash" do
      @subject.add_inputs a: Chingu::GameStates::Pause, b: Chingu::GameState

      expect(@subject.input).to eq({ a: [Chingu::GameStates::Pause],
                                     b: [Chingu::GameState] })
    end

    it "sets the input array" do
      allow(@subject).to receive(:a)
      allow(@subject).to receive(:b)

      @subject.add_inputs :a, :b

      expect(@subject.input).to eq({ a: [@subject.method(:a)],
                                     b: [@subject.method(:b)] })
    end

    # Not bothering with all the options, since it is tested fully, though
    # indirectly, in #on_input already. I suspect it might be better to put
    # the logic in on_input rather than in input too. Mmm.
    it "should do other stuff"
  end

  describe "#on_input" do
    it "adds a handler that is given as a block" do
      block = -> {}
      @subject.on_input :a, &block

      expect(@subject.input).to eq({ a: [block] })
    end

    it "adds a handler that is given as a method" do
      @subject.on_input :a, @handler1

      expect(@subject.input).to eq({ a: [@handler1] })
    end

    it "adds a handler that is given as a proc" do
      proc = -> { puts "Hello" }
      @subject.on_input :a, proc

      expect(@subject.input).to eq({ a: [proc] })
    end

    [:handler1, "handler1"].each do |handler|
      it "adds a handler that is given as a #{handler.class}" do
        @subject.on_input :a, handler

        expect(@subject.input).to eq({ a: [@handler1] })
      end
    end

    it "adds multiple handlers for the same event" do
      @subject.on_input :a, @handler1
      @subject.on_input :a, @handler2

      expect(@subject.input).to eq({ a: [@handler1, @handler2] })
    end

    it "automatically handles to a method if only the input is given" do
      allow(@subject).to receive(:a)
      @subject.on_input :a

      expect(@subject.input).to eq({ a: [@subject.method(:a)] })
    end

    it "adds multiple handlers for the same event, even if given different key names" do
      @subject.on_input :left, @handler1
      @subject.on_input :left_arrow, @handler2

      expect(@subject.input).to eq({ left_arrow: [@handler1, @handler2] })
    end

    it "adds a handler that is given as a Chingu::GameState class" do
      @subject.on_input :a, Chingu::GameStates::Pause

      expect(@subject.input).to eq({ a: [Chingu::GameStates::Pause] })
    end

    it "adds a handler that is given as a Chingu::GameState instance" do
      state = Chingu::GameState.new
      @subject.on_input :a, state

      expect(@subject.input).to eq({ a: [state] })
    end

    it "raises an error if given an unknown key" do
      expect do
        @subject.on_input :aardvark, @handler1
      end.to raise_error(ArgumentError)
    end

    it "should raise an error if given an incorrect action" do
      expect do
        @subject.on_input :a, 47
      end.to raise_error(ArgumentError)
    end

    it "adds a new handler if one already exists for that input" do
      @subject.on_input :a, @handler1
      @subject.on_input :b, @handler2

      expect(@subject.input).to eq({ a: [@handler1], b: [@handler2] })
    end

    it "considers all key synonyms the same" do
      @subject.on_input :left, @handler1
      @subject.on_input :left_arrow, @handler2

      expect(@subject.input).to eq({ left_arrow: [@handler1, @handler2] })
    end

    it "splits up and standardize key arrays" do
      @subject.on_input(%i[space left], @handler1)

      expect(@subject.input).to eq({ " ": [@handler1],
                                     left_arrow: [@handler1] })
    end

    it "raises an error if both an action and a hander are given" do
      block = -> { p "hello world" }
      expect do
        @subject.on_input :a, "Hello", &block
      end.to raise_error(ArgumentError)
    end
  end
end
