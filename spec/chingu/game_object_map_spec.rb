# frozen_string_literal: true

require 'spec_helper'

# Create 20x20 pixel sized objects
class MyGameObject < Chingu::GameObject
  trait :bounding_box

  def setup
    @image = Gosu::Image['rect_20x20.png']

    self.rotation_center = :top_left
  end
end

# Create 40x40 pixel sized objects
class MyBigGameObject < Chingu::GameObject
  trait :bounding_box

  def setup
    @image = Gosu::Image['rect_20x20.png']

    self.rotation_center = :top_left
    self.size = [40, 40]
  end
end

describe Chingu::GameObjectMap do
  before do
    @game = Chingu::Window.new

    # Add images/ to the resources load path
    Gosu::Image.autoload_dirs
               .unshift(File.expand_path('images', File.dirname(__FILE__)))

    MyGameObject.destroy_all
    MyBigGameObject.destroy_all

    @game_object = MyGameObject.create
    @big_game_object = MyBigGameObject.create

    @grid_size = [20, 20]
  end

  after do
    @game.close
  end

  context 'Setup with grid size 20x20 consists of' do
    it 'one MyGameObject' do
      expect(MyGameObject.size).to eq(1)
    end
    it 'one MyBigGameObject' do
      expect(MyBigGameObject.size).to eq(1)
    end
  end

  context 'Containing a game object of size 20x20 at position (0, 0)' do
    before  do
      @game_object_map = described_class.new(game_objects: MyGameObject.all, grid: @grid_size)
    end

    it 'is found at (0, 0)' do
      expect(@game_object_map.at(0, 0)).to eq(@game_object)
    end

    it 'is found at (10, 10)' do
      expect(@game_object_map.at(10, 10)).to eq(@game_object)
    end

    # I have so many questions...
    it 'is found at (20, 20)' do
      expect(@game_object_map.at(20, 20)).to be_nil
    end

    it 'is not found at (21, 21)' do
      expect(@game_object_map.at(21, 21)).to be_nil
    end
  end

  context 'Containing a game object of size 40x40 at position (0, 0)' do
    before do
      @game_object_map = described_class.new(game_objects: MyBigGameObject.all, grid: @grid_size)
    end

    it 'is found at (0, 0)' do
      expect(@game_object_map.at(0, 0)).to eq(@big_game_object)
    end
    it 'is found at (20, 20)' do
      expect(@game_object_map.at(20, 20)).to eq(@big_game_object)
    end
    it 'is found at (39, 39)' do
      expect(@game_object_map.at(39, 39)).to eq(@big_game_object)
    end

    it 'is not be found at (40, 40)' do
      expect(@game_object_map.at(40, 40)).to be_nil
    end
  end

  context 'Containing game objects of size 20x20 at position (100, 100) and ' \
          'position (1, 1)' do
    before do
      @other_game_object = MyGameObject.create
      @other_game_object.x = @other_game_object.y = 1

      @game_object.x = @game_object.y = 100

      @game_object_map = described_class.new(game_objects: MyGameObject.all, grid: @grid_size)
    end

    context 'When a player game object is at (50, 100)' do
      before do
        @player = MyGameObject.create
        @player.x = 50
        @player.y = 100
      end

      context 'And a dest game object is at (80, 100)' do
        before do
          @dest = MyGameObject.create
          @dest.x = 80
          @dest.y = 100
        end

        it '#game_object_between? returns false' do
          expect(@game_object_map.game_object_between?(@player,
                                                       @dest)).not_to be_truthy
        end
      end

      context 'And a dest game object is at (150, 100)' do
        before do
          @dest = MyGameObject.create
          @dest.x = 150
          @dest.y = 100
        end

        # FIXME: Long lines

        it '#game_object_between? returns true' do
          expect(@game_object_map.game_object_between?(@player,
                                                       @dest)).to be_truthy
        end

        it '#game_object_between? with target: the grid object between ' \
           'player and dest returns true' do
          expect(@game_object_map.game_object_between?(@player,
                                                       @dest,
                                                       target: @game_object)).to be_truthy
        end

        it '#game_object_between? with target: the grid object at (1, 1) ' \
           'returns false' do
          expect(@game_object_map.game_object_between?(@player,
                                                       @dest,
                                                       target: @other_game_object)).not_to be_truthy
        end

        it '#game_object_between? with only: the game object class of the ' \
           'grid object returns false' do
          expect(@game_object_map.game_object_between?(@player,
                                                       @dest,
                                                       only: @game_object.class)).to be_truthy
        end

        it '#game_object_between? with only: a different game object ' \
           'returns false' do
          expect(@game_object_map.game_object_between?(@player,
                                                       @dest,
                                                       only: @big_game_object.class)).not_to be_truthy
        end
      end
    end
  end
end
