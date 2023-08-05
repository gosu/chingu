# frozen_string_literal: true

require 'spec_helper'

describe Chingu::Parallax do
  before do
    @window = Chingu::Window.new

    # Add images/ to the resources load path
    Gosu::Image.autoload_dirs
               .prepend(File.expand_path('images', File.dirname(__FILE__)))
  end

  after do
    @window.close
  end

  context 'When adding layers' do
    it 'has 3 different ways of adding layers' do
      subject << { image: 'rect_20x20.png', repeat_x: true, repeat_y: true }
      subject.add_layer(image: 'rect_20x20.png', repeat_x: true, repeat_y: true)
      subject << Chingu::ParallaxLayer.new(image: 'rect_20x20.png', repeat_x: true, repeat_y: true)

      expect(subject.layers.count).to eq(3)
    end

    it 'has incrementing z-order' do
      3.times do
        subject.add_layer(image: 'rect_20x20.png')
      end

      expect(subject.layers[1].zorder).to eq(subject.layers[0].zorder + 1)
      expect(subject.layers[2].zorder).to eq(subject.layers[0].zorder + 2)
    end

    it 'starts incrementing z-order in layers from Parallax-instance z-order if available' do
      parallax = described_class.new(zorder: 2000)

      3.times { parallax.add_layer(image: 'rect_20x20.png') }

      expect(parallax.layers[0].zorder).to eq(2000)
      expect(parallax.layers[1].zorder).to eq(2001)
      expect(parallax.layers[2].zorder).to eq(2002)
    end
  end
end
