module Battle::Animations::Transitions
  class Transition < Animation::Container
    include Battle::Constants
    # Create a 3D array, that maps the combinations of the three factors to a transition
    @@transitions = Array.new 2, (Array.new 4, (Array.new 4))
    @@transitions[DAY,WILD] = @@transitions[DAY,DOUB_WILD] = [:Snake_Squares, :Diagonal_Bubble_TL, :Diagonal_Bubble_BR, :Rising_Splash]
    @@transitions[NIGHT,WILD] = @@transitions[NIGHT,DOUB_WILD] = [:Snake_Squares, :DiagonalBubbleBR, :DiagonalBubbleBR, :RisingSplash]
    @@transitions[DAY,TRAINER] = [:TwoBallPass, :ThreeBallDown, :BallDown, :WavyThreeBallUp]
    @@transitions[NIGHT,TRAINER] = [:SpinBallSplit, :BallDown, :BallDown, :WavySpinBall]
    @@transitions[DAY,DOUB_TRAINER] = @@transitions[NIGHT,DOUB_TRAINER] = [:FourBallBurst] * 4


    @@duration = 1.25

    def self.animate time, location, type
      #symbol = @@transitions[time][location][type]
      symbol = :Snake_Squares
      return Battle::Animations::Transitions.const_get(symbol).new @@duration
    end

    def initialize *args
      super
      @sprites_to_dispose = []
    end

    def dispose
      @sprites_to_dispose.each {|s| s.dispose}
      super
    end

  end
end
