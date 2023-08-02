# frozen_string_literal: true

require 'spec_helper'

describe Chingu::Console do
  before do
    @console = Chingu::Console.new
  end

  after do
    $window = nil
  end

  it { is_expected.to respond_to(:start) }
  it { is_expected.to respond_to(:fps) }
  it { is_expected.to respond_to(:update) }
  it { is_expected.to respond_to(:root) }
  it { is_expected.to respond_to(:game_state_manager) }
  it { is_expected.to respond_to(:root) }
  it { is_expected.to respond_to(:milliseconds_since_last_tick) }

  context 'When initialized' do
    it 'returns itself as current scope' do
      expect(@console.current_scope).to eq(@console)
    end

    it 'has 0 game objects' do
      expect(@console.game_objects.size).to eq(0)
    end
  end

  context 'Each game iteration' do
    it '#update() should call update() on all unpaused game objects' do
      expect(Chingu::GameObject.create).to receive(:update)
      expect(Chingu::GameObject.create(paused: true)).not_to receive(:update)

      @console.update
    end

    it 'increments $window.ticks' do
      expect(@console.ticks).to eq(0)

      @console.update
      expect(@console.ticks).to eq(1)

      @console.update
      expect(@console.ticks).to eq(2)
    end
  end
end
