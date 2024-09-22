module Battle::Animations
  class Screen_Flash < Animation::PointBased 
    def initialize time, location
      c = (time == :night || location == :cave) ? 0 : 255
      viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      viewport.z = 99999
      viewport.color = Color.new c, c, c
      super (->(v) {viewport.color.alpha = v}), [0.2,255], [0.4,0], [0.6,255], [0.8,0]
    end
  end
end
