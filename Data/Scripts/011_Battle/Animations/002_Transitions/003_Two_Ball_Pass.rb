module Battle::Animations::Transitions      
  #=============================================================================
  # HGSS trainer outdoor day
  #=============================================================================
  class Two_Ball_Pass
    def self.play duration
      screen = Animation::Animated_Sprite.new
      screen.bitmap = Graphics.snap_to_bitmap
      # Two balls, one spinning in from left, one from right
      2.times do |i|
        b = Animation::Animated_Sprite.new
        b.bitmap = RPG::Cache.transition "ball_small"
        b.change_origin PictureOrigin::Center
        mult = i*2-1
        b.y = (Graphics.height - mult*b.bitmap.height)/2
        b.create_curve :angle, [0.25, mult*360], looping: true
        offset =  mult*(Graphics.width + b.bitmap.width)/2
        b.create_curve :x, [0, Graphics.width/2 + offset], [duration*0.6, Graphics.width/2 - offset]
      end
      Animation.wait_until_all_finished
      middle = [Graphics.width/2,Graphics.height/2]
      # Zoom onto player
      screen.change_origin PictureOrigin::Center
      screen.x, screen.y = middle 
      screen.create_curve ->(o,v) {o.zoom_x=v;o.zoom_y=v}, [0,1], [duration*0.4,2]
      # Apature effect
      black_middle = Transitions.gen_black_square
      black_middle.add_curve(Animation::Quadratic_Simple_Animation.new :zoom_y, [0,0], [duration*0.6,1])
      2.times do |i|
        mult = i*2-1
        black_lr = Transitions.gen_black_square
        black_lr.y = Graphics.height/2 - mult*Graphics.height/2
        black_lr.create_curve :x, [0,Graphics.width/2 + mult*Graphics.width], [duration*0.6, Graphics.width/2]
      end

      Animation.wait_until_all_finished
    end
  end
end
