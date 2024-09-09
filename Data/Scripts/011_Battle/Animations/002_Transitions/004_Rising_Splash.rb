module Battle::Animations::Transitions
  #=============================================================================
  # HGSS wild water
  #=============================================================================
  class Rising_Splash
    def self.play duration
      screen = Animation::Animated_Sprite.new
      screen.bitmap = Graphics.snap_to_bitmap
      screen.wave_length = 74
      screen.create_curve :wave_phase, [duration, 3600]
      screen.create_curve :wave_amp, [0.1,6]
      
      sprite = Animation::Animated_Sprite.new
      sprite.bitmap = RPG::Cache.transition("water_1")
      sprite.create_curve :y, [0,Graphics.height], [duration,-Graphics.height]
      sprite.add_curve(Animation::Sin_Animation.new :x, duration, amplitude: 32, wave_length: 2*Math::PI)

      splash = Animation::Animated_Sprite.new
      splash.bitmap = RPG::Cache.transition("water_2")
      splash.create_curve :y, [0, Graphics.height], [duration/2, Graphics.height], [duration, -Graphics.height]
      
      black_half = Transitions.gen_black_square center: false 
      pos = Graphics.height+0.95*splash.bitmap.height
      black_half.create_curve :y, [0, pos], [duration/2, pos], [duration, 0]

      Animation.wait_until_all_finished w_dispose: true
    end
  end
end
