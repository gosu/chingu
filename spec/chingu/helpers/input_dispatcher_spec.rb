# frozen_string_literal: true

require 'spec_helper'

describe Chingu::Helpers::InputDispatcher do
  before do
    @subject = Object.new.extend described_class
    @client = Object.new
  end

  it 'should respond to methods' do
    expect(@subject).to respond_to(:input_clients)
    expect(@subject).to respond_to(:add_input_client)
    expect(@subject).to respond_to(:remove_input_client)
  end

  { 'button_down' => :a, 'button_up' => :released_a }.each_pair do |event, key|
    describe "#dispatch_#{event}" do
      it 'dispatchs key event if key is handled' do
        expect(@client).to receive(:handler).with(no_args)

        allow(@client).to receive(:input).with(no_args) {
           { key => [@client.method(:handler)] }
         }

        @subject.send("dispatch_#{event}", Gosu::KbA, @client)
      end

      it 'does not dispatch key event if key is not handled' do
        allow(@client).to receive(:input).with(no_args) { {} }

        @subject.send("dispatch_#{event}", Gosu::KbA, @client)
      end
    end
  end

  describe '#dispatch_input_for' do
    before do
      $window = double(Chingu::Window)
      allow($window).to receive(:button_down?) { false }
    end

    after do
      $window = nil
    end

    it 'dispatchs if a key is being held' do
      expect(@client).to receive(:handler).with(no_args)

      allow($window).to receive(:button_down?).with(Gosu::KbA) { true }

      allow(@client).to receive(:input).with(no_args) { { holding_a: [@client.method(:handler)] } }
      @subject.dispatch_input_for(@client)
    end

    it 'do nothing if a key is not held' do
      allow(@client).to receive(:input).with(no_args) {
        { holding_a: [-> { raise "Shouldn't handle input!" }] }

      }
      @subject.dispatch_input_for(@client)
    end
  end

  describe '#dispatch_actions' do
    it 'calls a method' do
      expect(@client).to receive(:handler).with(no_args)

      @subject.send(:dispatch_actions, [@client.method(:handler)])
    end

    it 'calls a proc' do
      expect(@client).to receive(:handler)

      @subject.send(:dispatch_actions, [-> { @client.handler }])
    end

    it 'will push a game-state instance' do
      state = Chingu::GameState.new

      expect(@subject).to receive(:push_game_state).with(state)

      @subject.send(:dispatch_actions, [state])
    end

    it 'will push a game-state class' do
      expect(@subject).to receive(:push_game_state).with(Chingu::GameState)

      @subject.send(:dispatch_actions, [Chingu::GameState])
    end

    it 'calls multiple actions if more have been set' do
      other = Object.new
      expect(other).to receive(:handler).with(no_args)

      expect(@client).to receive(:handler).with(no_args)

      @subject.send(:dispatch_actions, [@client.method(:handler), other.method(:handler)])
    end

    # NOTE: Doesn't check if a passed class is incorrect. Life is too short.
    it 'raises an error with unexpected data' do
      expect do
        @subject.send(:dispatch_actions, [12])
      end.to raise_error(ArgumentError)
    end
  end
end
