module Battle::Animations
  class Start_Text < Animation::Container
    def initialize
      messageBG = Animation::Implementations::Animated_Sprite.new viewport
      messageBG.y = Graphics.height - 96
      messageBG.bitmap = Bitmap.new "Graphics/Pictures/Battle/overlay_message"
      message_window = Window_AdvancedTextPokemon.new x: 16, y: Graphics.height - 96 + 2, width: Graphics.width - 32, height: 96, viewport: viewport
      message_window.letterbyletter = true
    end
  end
end
