# frozen_string_literal: true

require 'spec_helper'

describe Chingu::GameObject do
  before do
    @game = Chingu::Window.new

    # Add images/ to the resources load path
    Gosu::Image.autoload_dirs
               .unshift(File.expand_path('images', File.dirname(__FILE__)))
  end

  after do
    @game.close
  end

  it { is_expected.to respond_to(:x) }
  it { is_expected.to respond_to(:y) }
  it { is_expected.to respond_to(:angle) }
  it { is_expected.to respond_to(:center_x) }
  it { is_expected.to respond_to(:center_y) }
  it { is_expected.to respond_to(:factor_x) }
  it { is_expected.to respond_to(:factor_y) }
  it { is_expected.to respond_to(:zorder) }
  it { is_expected.to respond_to(:mode) }
  it { is_expected.to respond_to(:color) }
  it { is_expected.to respond_to(:attributes) }
  it { is_expected.to respond_to(:draw) }
  it { is_expected.to respond_to(:draw_at) }
  it { is_expected.to respond_to(:draw_relative) }

  context 'When created with defaults' do
    it 'has default values' do
      expect(subject.angle).to eq(0)
      expect(subject.x).to eq(0)
      expect(subject.y).to eq(0)
      expect(subject.zorder).to eq(100)
      expect(subject.factor_x).to eq(1)
      expect(subject.factor_y).to eq(1)
      expect(subject.center_x).to eq(0.5)
      expect(subject.center_y).to eq(0.5)
      expect(subject.mode).to eq(:default)
      expect(subject.image).to eq(nil)
      expect(subject.color).to eq(Gosu::Color::WHITE)
      expect(subject.alpha).to eq(255)
    end

    it 'wraps angle at 360' do
      expect(subject.angle).to eq(0)
      subject.angle += 30
      expect(subject.angle).to eq(30)
      subject.angle += 360
      expect(subject.angle).to eq(30)
    end

    # TODO: I think we should just combine this two tests into one named
    #       'clamps alpha between 0 and 255'
    it "doesn't allow alpha below 0" do
      subject.alpha = -10
      expect(subject.alpha).to eq(0)
    end

    it "doesn't allow alpha above 255" do
      subject.alpha = 1000
      expect(subject.alpha).to eq(255)
    end
  end

  it 'has the same value for self.alpha as self.color.alpha' do
    expect(subject.alpha).to eq(subject.color.alpha)
  end

  it 'has a correct filename created from class name' do
    expect(subject.filename).to eq('game_object')
  end

  it 'raises an exception if the image fails to load' do
    expect {
      described_class.new(image: 'monkey_with_a_nuclear_tail.png')
    }.to raise_error(Exception)
  end

  context 'Position' do
    it '#inside_window?' do
      subject.x = 1
      subject.y = 1

      expect(subject.inside_window?).to be_truthy
      expect(subject.outside_window?).to be_falsy
    end
    it '#outside_window?' do
      subject.x = @game.width + 1
      subject.y = @game.height + 1

      expect(subject.inside_window?).to be_falsy
      expect(subject.outside_window?).to be_truthy
    end
  end

  context 'Setters' do
    it 'factor sets both factor_x and factor_y' do
      subject.factor = 4

      expect(subject.factor_x).to eq(4)
      expect(subject.factor_y).to eq(4)
    end

    it 'scale is an alias for factor' do
      subject.scale = 5

      expect(subject.factor).to eq(5)
    end
  end

  context 'Visibility' do
    it 'will hide/show object on self.hide! and self.show!' do
      subject.hide!
      expect(subject.visible?).to be_falsy

      subject.show!
      expect(subject.visible?).to be_truthy
    end
  end

  context 'When created with an image named in a string' do
    subject { described_class.new(image: 'rect_20x20.png') }

    it 'has width, height & size' do
      expect(subject.height).to eq(20)
      expect(subject.width).to eq(20)
      expect(subject.size).to eq([20, 20])
    end

    it 'adapts width, height & size to scaling' do
      subject.factor = 2

      expect(subject.height).to eq(40)
      expect(subject.width).to eq(40)
      expect(subject.size).to eq([40, 40])
    end

    it 'adapts factor_x/factor_y to new size' do
      subject.size = [10, 40]  # Half the width, double the height

      expect(subject.width).to eq(10)
      expect(subject.height).to eq(40)

      expect(subject.factor_x).to eq(0.5)
      expect(subject.factor_y).to eq(2)
    end
  end

  context 'When created with multiple arguments' do
    subject { described_class.new(image: 'rect_20x20.png', size: [10, 10]) }

    it 'initializes values correctly' do
      expect(subject.width).to eq(10)
      expect(subject.height).to eq(10)
    end
  end

  context "When there's a global factor/scale" do
    before do
      $window.factor = 2
    end

    subject { described_class.new(image: 'rect_20x20.png') }

    it 'uses global factor/scale' do
      expect(subject.factor_x).to eq(2)
      expect(subject.factor_y).to eq(2)

      expect(subject.width).to eq(40)
      expect(subject.height).to eq(40)
    end
  end

  context "When there's missing parts" do
    it "returns nil on width and height if there's no image available" do
      game_object = described_class.new

      expect(game_object.width).to be_nil
      expect(game_object.height).to be_nil
    end
  end

  context 'Class methods' do
    it 'Goes through all instances of class on #each' do
      described_class.destroy_all

      go1 = described_class.create
      go2 = described_class.create

      index = 0
      described_class.each do |game_object|
        expect(game_object).to eq(go1) if index == 0
        expect(game_object).to eq(go2) if index == 1

        index += 1
      end
    end

    it 'Goes through all instances of class on #each_with_index' do
      described_class.destroy_all

      go1 = described_class.create
      go2 = described_class.create

      described_class.each_with_index do |game_object, index|
        expect(game_object).to eq(go1) if index == 0
        expect(game_object).to eq(go2) if index == 1
      end
    end
  end
end
