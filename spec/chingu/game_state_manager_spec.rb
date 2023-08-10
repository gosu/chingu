# frozen_string_literal: true

require "spec_helper"

describe Chingu::GameStateManager do
  before do
    @game = Chingu::Window.new
  end

  after do
    @game.close
  end

  describe "Initial configuration" do
    it "$window has a game_state_manager" do
      expect(@game.game_state_manager).not_to be_nil
    end
    it "has 0 game states" do
      expect(@game.game_state_manager.game_states.count).to eq(0)
    end
  end

  describe "#push_game_state" do
    before do
      @game.push_game_state(Chingu::GameStates::Pause)
      @game.push_game_state(Chingu::GameStates::Edit)
    end

    it "changes current game state" do
      expect(@game.current_game_state.class).to eq(Chingu::GameStates::Edit)
    end

    it "keeps last game state" do
      expect(@game.game_state_manager.previous_game_state.class).to be_truthy
      expect(@game.current_game_state.class).to eq(Chingu::GameStates::Edit)
    end

    it "increments total number of game states" do
      expect(@game.game_states.count).to eq(2)
    end
  end

  describe "#pop_game_state" do
    before do
      @game.push_game_state(Chingu::GameStates::Pause)
      @game.push_game_state(Chingu::GameStates::Edit)
    end

    it "replaces current game state with last one" do
      @game.pop_game_state
      expect(@game.current_game_state.class).to eq(Chingu::GameStates::Pause)
    end

    it "decrements total number of game states" do
      @game.pop_game_state
      expect(@game.game_states.count).to eq(1)
    end
  end

  describe "#switch_game_state" do
    before do
      @game.push_game_state(Chingu::GameStates::Pause)
      @game.switch_game_state(Chingu::GameStates::Debug)
    end

    it "replaces current game state" do
      expect(@game.current_game_state).to be_a(Chingu::GameStates::Debug)
    end

    it "does not change the total amount of game states" do
      expect(@game.game_states.count).to eq(1)
    end
  end

  describe "#pop_until_game_state" do
    before do
      @game.push_game_state(Chingu::GameStates::Pause)
      @game.push_game_state(Chingu::GameStates::Debug)
      @game.push_game_state(Chingu::GameStates::Debug)

      @states = @game.game_state_manager.instance_variable_get(:@game_states).dup
    end

    describe "With class" do
      it "finalizes popped states" do
        expect(@states[1]).to receive(:finalize)
        expect(@states[2]).to receive(:finalize)

        @game.pop_until_game_state(Chingu::GameStates::Pause)
      end

      it "setups revealed states" do
        expect(@states[0]).to receive(:setup)
        expect(@states[1]).to receive(:setup)

        @game.pop_until_game_state(Chingu::GameStates::Pause)
      end

      it "pops down to the given game state" do
        @game.pop_until_game_state(Chingu::GameStates::Pause)
        expect(@game.game_states).to eq([@states[0]])
      end
    end

    describe "With instance" do
      it "finalizes popped states" do
        expect(@states[1]).to receive(:finalize)
        expect(@states[2]).to receive(:finalize)

        @game.pop_until_game_state(@states[0])
      end

      it "setups revealed states" do
        expect(@states[0]).to receive(:setup)
        expect(@states[1]).to receive(:setup)

        @game.pop_until_game_state(@states[0])
      end

      it "pops down to the given game state" do
        @game.pop_until_game_state(@states[0])

        expect(@game.game_states).to eq([@states[0]])
      end
    end
  end

  describe "#clear_game_states" do
    it "clears all game states" do
      @game.push_game_state(Chingu::GameStates::Pause)
      @game.push_game_state(Chingu::GameStates::Edit)

      @game.clear_game_states

      expect(@game.game_states.count).to eq(0)
    end
  end

  describe "#transitional_game_state" do
    before do
      @game.transitional_game_state(Chingu::GameStates::FadeTo)

      @game.push_game_state(Chingu::GameStates::Pause)
      @game.push_game_state(Chingu::GameStates::Edit)
    end

    # it "should get back to the last game state after popping" do
    #  @game.pop_game_state
    #  @game.update
    #  sleep 4
    #  @game.update
    #  @game.current_game_state.class.should == Chingu::GameStates::Pause
    # end

    it "keeps track of amount of created game states" do
      expect(@game.game_states.count).to eq(2)
    end
  end
end
