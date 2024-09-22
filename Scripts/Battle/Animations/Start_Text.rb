module Battle::Animations
  class Start_Text < Animation::Sequential

    # Generates a string of the form "p1, p2, [...] pn-1 and pn"
    def list_names party, number
      text = party[0]
      party[0...number-1].each_cons(2) {|_,p| text += ", " + p}
      text += " and " + party[number-1] if number > 1
      return text
    end

    def initialize message_window, sides, type, party1, party2
      introduction_text = "Oh! A wild " + list_names(party2.map!{|p| p.name}, sides[1]) + " appeared!"
      
      super(
        message_window.generate_letter_animation(introduction_text)
      )

    end

    def self.setup_message_window
      messageBG = Animation::Implementations::Animated_Sprite.new
      messageBG.y = Graphics.height - 96
      messageBG.bitmap = Bitmap.new "Graphics/Pictures/Battle/overlay_message"
      message_window = Window_AdvancedTextPokemon.new x: 16, y: Graphics.height - 96 + 2, width: Graphics.width - 32, height: 96
      return message_window
    end


  end
end
