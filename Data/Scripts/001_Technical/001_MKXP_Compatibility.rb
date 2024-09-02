# Using mkxp-z v2.2.0 - https://gitlab.com/mkxp-z/mkxp-z/-/releases/v2.2.0
require 'debug'
$VERBOSE = nil
Font.default_shadow = false if Font.respond_to?(:default_shadow)
Graphics.frame_rate = 40

def pbSetWindowText(string)
  System.set_window_title(string || System.game_title)
end

class Bitmap
  attr_accessor :storedPath

  alias mkxp_draw_text draw_text unless method_defined?(:mkxp_draw_text)

  def draw_text(x, y, width, height, text, align = 0)
    height = text_size(text).height
    mkxp_draw_text(x, y, width, height, text, align)
  end
end

module Graphics
  def self.delta_s
    return self.delta.to_f / 1_000_000
  end

  class << self
    attr_accessor :time
    attr_accessor :delta_end
    attr_accessor :time_multiplier
  end
  self.time = 0
  self.delta_end = 0
  self.time_multiplier = 1

  class << Graphics
    alias mkxpz_update update
  end

  def self.update
    self.delta_end = self.time_multiplier * self.delta
    self.time += self.delta_end
    mkxpz_update
    return delta
  end
end

def pbSetResizeFactor(factor)
  if !$ResizeInitialized
    Graphics.resize_screen(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    $ResizeInitialized = true
  end
  if factor < 0 || factor == 4
    Graphics.fullscreen = true if !Graphics.fullscreen
  else
    Graphics.fullscreen = false if Graphics.fullscreen
    Graphics.scale = (factor + 1) * 0.5
    Graphics.center
  end
end
