# frozen_string_literal: true

require 'spec_helper'

class MyBasicGameObject < Chingu::BasicGameObject; end

class MyBasicGameObject2 < Chingu::BasicGameObject; end

class MyBasicGameObjectWithSetup < Chingu::BasicGameObject
  def setup
    @paused = true
  end
end

describe Chingu::BasicGameObject do
  before do
    @game = Chingu::Window.new
  end

  after do
    @game.close
  end

  it { is_expected.to respond_to(:options) }
  it { is_expected.to respond_to(:paused) }
  it { is_expected.to respond_to(:setup_trait) }
  it { is_expected.to respond_to(:setup) }
  it { is_expected.to respond_to(:update_trait) }
  it { is_expected.to respond_to(:draw_trait) }
  it { is_expected.to respond_to(:filename) }

  context 'With a class inherited from BasicGameObject using #create' do
    it 'is automatically stored in $window.game_objects' do
      MyBasicGameObject.instances = []
      3.times { MyBasicGameObject.create }

      expect($window.game_objects.size).to eq(3)
    end

    it 'has $window as parent' do
      go = MyBasicGameObject.create

      expect(go.parent).to eq($window)
    end

    it 'keeps track of its instances in #all' do
      MyBasicGameObject.instances = []
      3.times { MyBasicGameObject.create }

      # Can/should we remove the dependency on #update here before the created
      # objects gets saved? We mostly protect against adding to the object
      # array while iterating over it
      expect(MyBasicGameObject.all.size).to eq(3)
      expect(MyBasicGameObject.size).to eq(3)
    end

    it 'is removed from game_objects list when #destroy is called' do
      MyBasicGameObject.instances = []
      go = MyBasicGameObject.create
      expect($window.game_objects.size).to eq(1)

      go.destroy
      expect($window.game_objects.size).to eq(0)
    end

    it 'hass all internal list cleared with #destroy_all()' do
      MyBasicGameObject.instances = []
      3.times { MyBasicGameObject.create }
      MyBasicGameObject.destroy_all

      expect(MyBasicGameObject.size).to eq(0)
    end

    it 'has all instances removed from parent-list with #destroy_all()' do
      MyBasicGameObject.instances = []
      3.times { MyBasicGameObject.create }
      MyBasicGameObject.destroy_all

      expect($window.game_objects.size).to eq(0)
    end
  end

  context 'With a class inherited from BasicGameObject' do
    it 'returns empty array on #all if no objects have been created' do
      # Only place MyBasicGameObject2 is used
      expect(MyBasicGameObject2.all).to eq([])
    end

    it 'takes extra keyword arguments, parses and saves them in options' do
      MyBasicGameObject.instances = []
      game_object = MyBasicGameObject.new(paused: false, foo: :bar)

      expect(game_object.paused?).to be_falsy
      expect(game_object.options).to eq({ paused: false, foo: :bar })
    end

    it 'calls #setup at the end of initialization' do
      game_object = MyBasicGameObjectWithSetup.new(paused: false)

      expect(game_object.paused?).to be_truthy
    end

    it 'is unpaused by default' do
      expect(subject.paused?).to be_falsy
    end

    it 'changes paused status with #pause/#unpause' do
      subject.pause
      expect(subject.paused?).to be_truthy
      subject.unpause
      expect(subject.paused?).to be_falsy
    end

    it 'gives a correctly named string with #filename' do
      expect(MyBasicGameObject.new.filename).to eq('my_basic_game_object')
    end
  end

  context 'When created with defaults in Chingu::Window' do
    it 'belongs to main window if not created inside a game state' do
      expect(subject.parent).to eq(@game)
    end
  end

  context 'When created in Chingu::GameState' do
    # TODO
  end
end
