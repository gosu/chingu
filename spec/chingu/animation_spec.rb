# frozen_string_literal: true

require 'spec_helper'

describe Chingu::Animation do
  before do
    @game = Chingu::Window.new

    @test_images = File.join(File.expand_path('images', File.dirname(__FILE__)))
    Gosu::Image.autoload_dirs << @test_images

    @file = 'droid_11x15.bmp'

    @animation_clean = described_class.new(file: @file)
    @animation = described_class.new(file: @file, delay: 0)
  end

  after do
    @game.close
  end

  describe 'When initialized' do
    it 'has default values' do
      expect(@animation_clean.bounce).to be_falsy
      expect(@animation_clean.loop).to be_truthy

      expect(@animation_clean.delay).to eq(100)
      expect(@animation_clean.index).to eq(0)
      expect(@animation_clean.step).to eq(1)
    end

    it 'finds single filename in Image.autoload_dirs' do
      @anim = described_class.new(file: 'droid_11x15.bmp')

      expect(@anim.frames.count).to eq(14)
    end

    it 'finds relative filename path' do
      Dir.chdir(File.dirname(File.expand_path(__FILE__)))
      @anim = described_class.new(file: 'images/droid_11x15.bmp')

      expect(@anim.frames.count).to eq(14)
    end

    it 'loads from a Gosu image' do
      Dir.chdir(File.dirname(File.expand_path(__FILE__)))
      @anim = described_class.new(image: Gosu::Image['images/droid_11x15.bmp'],
                                  size: [11, 15])

      expect(@anim.frames.count).to eq(14)
    end
  end

  describe 'Animation loading using :frames' do
    it 'has the same frames' do
      anim = described_class.new(frames: @animation_clean.frames)

      expect(anim.frames).to eq(@animation_clean.frames)
    end

    it 'rejects non-consistent frame sizes' do
      expect {
        described_class.new(frames: @animation_clean.frames + [Gosu::Image[@file]])
      }.to raise_error(ArgumentError)
    end
  end

  describe 'Animation loaded using :image' do
    before do
      @anim = described_class.new image: Gosu::Image[@file]
    end

    it 'has the same frames' do
      @anim.frames
           .zip(@animation_clean.frames).all? { |a, b| a.to_blob == b.to_blob }
    end
  end

  describe 'Animation loading exception handling' do
    it 'fails unless one of the creation paramaters is given' do
      expect {
        described_class.new
      }.to raise_error(ArgumentError)
    end

    it 'fails if more than one creation paramater is given' do
      expect {
        described_class.new(image: Gosu::Image[@file], file: @file)
      }.to raise_error(ArgumentError)
    end
  end

  describe 'Animation loading file: droid_11x15.bmp' do
    it 'detects size and frames automatically from filename' do
      expect(@animation.size).to eq([11, 15])
      expect(@animation.frames.count).to eq(14)
    end

    it 'gives correct frames for #first and #last' do
      expect(@animation.first).to eq(@animation.frames.first)
      expect(@animation.last).to eq(@animation.frames.last)
    end

    it 'returns frame with []' do
      expect(@animation[0]).to eq(@animation.frames.first)
    end

    it 'steps animation forward with #next' do
      @animation.next

      expect(@animation.index).to eq(1)
    end

    it 'stops animation when reaching end if loop and bounce are both false' do
      @animation.loop = false
      @animation.bounce = false
      @animation.index = 14
      @animation.next

      expect(@animation.index).to eq(14)
    end

    it 'loops animation when reaching end if loop is true' do
      @animation.index = 14
      @animation.next

      expect(@animation.index).to eq(0)
    end

    it 'bounces animation when reaching end if bounce is true' do
      @animation.bounce = true
      @animation.index = 14
      @animation.next

      expect(@animation.index).to eq(13)
    end

    it 'uses #step when moving animation forward' do
      @animation.step = 5
      @animation.next
      expect(@animation.index).to eq(5)

      @animation.next
      expect(@animation.index).to eq(10)
    end

    it "handles 'frame_names' pointing to a new animation containing a" \
       'subset of the original frames' do
      @animation.frame_names = { scan: 0..5,
                                 up: 6..7,
                                 down: 8..9,
                                 left: 10..11,
                                 right: 12..13 }

      expect(@animation[:scan]).to be_an(Chingu::Animation)
      expect(@animation[:scan].frames.count).to eq(6)
      expect(@animation[:up].frames.count).to eq(2)
      expect(@animation[:down].frames.count).to eq(2)
      expect(@animation[:left].frames.count).to eq(2)
      expect(@animation[:right].frames.count).to eq(2)
    end
  end
end
