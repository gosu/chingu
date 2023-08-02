# frozen_string_literal: true

require 'spec_helper'

describe Chingu::GameObjectList do
  before do
    @game = Chingu::Window.new
  end

  after do
    @game.close
  end

  it { is_expected.to respond_to(:draw) }
  it { is_expected.to respond_to(:update) }
  it { is_expected.to respond_to(:each) }
  it { is_expected.to respond_to(:each_with_index) }
  it { is_expected.to respond_to(:select) }
  it { is_expected.to respond_to(:first) }
  it { is_expected.to respond_to(:last) }
  it { is_expected.to respond_to(:show) }
  it { is_expected.to respond_to(:hide) }
  it { is_expected.to respond_to(:pause) }
  it { is_expected.to respond_to(:unpause) }

  context '$window.game_objects' do
    it 'returns created game objects' do
      go1 = Chingu::GameObject.create
      go2 = Chingu::GameObject.create

      expect(@game.game_objects.first).to eq(go1)
      expect(@game.game_objects.last).to eq(go2)
    end

    it 'is able to destroy game_objects while iterating' do
      10.times { Chingu::GameObject.create }

      @game.game_objects.each_with_index do |game_object, index|
        game_object.destroy if index >= 5
      end

      expect(@game.game_objects.size).to eq(5)
    end

    it 'calls update() on all unpaused game objects' do
      expect(Chingu::GameObject.create).to receive(:update)
      expect(Chingu::GameObject.create(paused: true)).not_to receive(:update)

      @game.game_objects.update
    end

    it 'keeps track of unpaused game objects' do
      go = Chingu::GameObject.create
      expect(go).to receive(:update)

      @game.game_objects.update

      go.pause
      expect(go).not_to receive(:update)

      @game.game_objects.update
    end

    it 'keeps track of visible game objects' do
      go = Chingu::GameObject.create
      expect(go).to receive(:draw)

      @game.game_objects.draw

      go.hide!
      expect(go).not_to receive(:draw)

      @game.game_objects.draw
    end

    it 'keeps track of visible game objects with #show!' do
      go = Chingu::GameObject.create(visible: false)
      go.show!
      expect(go).to receive(:draw)

      @game.game_objects.draw
    end

    it 'calls draw() on all visible game objects' do
      expect(Chingu::GameObject.create).to receive(:draw)
      expect(Chingu::GameObject.create(visible: false)).not_to receive(:draw)

      @game.game_objects.draw
    end

    it 'calls draw_relative() on all visible game objects' do
      expect(Chingu::GameObject.create).to receive(:draw_relative)
      expect(Chingu::GameObject.create(visible: false)).not_to receive(:draw_relative)

      @game.game_objects.draw_relative
    end

    it 'pauses all game objects with #pause!' do
      5.times { Chingu::GameObject.create }
      @game.game_objects.pause!

      @game.game_objects.each do |game_object|
        expect(game_object.paused).to be_truthy
      end
    end

    it 'hides all game objects with #hide!' do
      5.times { Chingu::GameObject.create }
      @game.game_objects.hide!

      @game.game_objects.each do |game_object|
        expect(game_object.visible).to be_falsy
      end
    end
  end
end
