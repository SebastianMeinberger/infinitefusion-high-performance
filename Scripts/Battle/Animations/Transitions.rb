module Battle::Animations::Transitions
  class Transition < Animation::Parralel 
    def initialize sprites_to_dispose, *animations  # determine the actual transition
      super(*animations)
      @sprites_to_dispose = sprites_to_dispose
    end

    def dispose
      @sprites_to_dispose.each {|s| s.dispose}
      super
    end

  end
end

require 'Battle/Animations/Transitions/Square_Transitions'
require 'Battle/Animations/Transitions/Rising_Splash'
require 'Battle/Animations/Transitions/Two_Ball_Pass'

module Battle::Animations::Transitions
  # Cach dictornaries to lookup which transition should be used
    # Day and night have the same transitions for wild encounters.
    @@wild = {inside: Snake_Squares, outside: Diagonal_Bubble_TL, cave: Diagonal_Bubble_BR, water: Rising_Splash}
    @@trainer = {
      day: {inside: Two_Ball_Pass},#, outside: Three_Ball_Down, cave: Ball_Down, water: Wavy_Spin_Ball},
      night: {}
    }
 
    # Factory method to construct correct transition
    def self.construct time, location, type, duration: 1.25
      #binding.b
      time, location, type = :day, :inside, :wild

      time = :night if time == :eve
      transition = case type
      when :wild, :doub_wild
        @@wild[location]
      when :trainer
        @@trainer[time, location]
      when :doub_trainer
        Four_Ball_Burst
      else
        # Shouldn't happen
        Snake_Squares
      end

      return transition.new duration
    end
end
