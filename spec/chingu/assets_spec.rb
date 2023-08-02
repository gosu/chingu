# frozen_string_literal: true

require 'spec_helper'

describe Chingu::NamedResource do
  before do
    @game = Chingu::Window.new

    # Add images/ to the resources load path
    Gosu::Image.autoload_dirs
               .unshift(File.expand_path('images', File.dirname(__FILE__)))
  end

  after do
    @game.close
  end

  describe 'Image' do
    it 'has default autoload dirs' do
      expect(Gosu::Image.autoload_dirs).to include('.')
      expect(Gosu::Image.autoload_dirs).to include("#{@game.root}/media")
    end

    it 'autoloads image in Image.autoload_dirs' do
      expect(Gosu::Image['rect_20x20.png']).to be_kind_of(Gosu::Image)
    end

    it 'returns the same cached Gosu::Image if requested twice' do
      expect(Gosu::Image['rect_20x20.png']).to eq(Gosu::Image['rect_20x20.png'])
    end

    #it "should raise error if image is nonexistent" do
    #  Gosu::Image["nonexistent_image.png"].should raise_error RuntimeError
    # end
  end

  describe 'Song' do
    it 'has default autoload dirs' do
      expect(Gosu::Song.autoload_dirs).to include('.')
      expect(Gosu::Song.autoload_dirs).to include("#{@game.root}/media")
    end
  end

  describe 'Sample' do
    it 'has default autoload dirs' do
      expect(Gosu::Sample.autoload_dirs).to include('.')
      expect(Gosu::Sample.autoload_dirs).to include("#{@game.root}/media")
    end
  end

  describe 'Font' do
    it 'has default autoload dirs' do
      expect(Gosu::Font.autoload_dirs).to include('.')
      expect(Gosu::Font.autoload_dirs).to include("#{@game.root}/media")
    end
  end
end
