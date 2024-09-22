module Battle::Animations
end

[:Transitions, :Screen_Flash, :Start_Text, :BG_Slide].each do |f|
  Battle::Animations.autoload f, "Battle/Animations/" + f.to_s
end
