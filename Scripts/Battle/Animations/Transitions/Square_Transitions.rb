module Battle::Animations::Transitions
  class Square_Transition < Transition
    require 'matrix'
    # All transitions using black squares, use the same bitmap and only adjust the src_rect of the holding sprite accordingly
    # This is set at class level, to avoid genereating a new bimap everytime
    @@black_bitmap = Bitmap.new Graphics.width, Graphics.height
    @@black_bitmap.fill_rect 0, 0, Graphics.width, Graphics.height, Color.new(0,0,0)
    def gen_black_square x: Graphics.width, y: Graphics.height, center: true
      sprite = Animation::Implementations::Animated_Sprite.new
      sprite.bitmap = @@black_bitmap
      sprite.src_rect = Rect.new 0, 0, x, y
      if center
        sprite.change_origin PictureOrigin::Center
        sprite.x, sprite.y = x/2, y/2
      end 
      return sprite
    end

    def initialize transition_duration, zoom_duration, squares, *properties, cx: 8, cy: 6
      animations = []
      sprites_to_dispose = []
      w, h = Graphics.width/cx, Graphics.height/cy 
      x_pos = w/2
      squares.each do |col|
        y_pos = h/2
        col.each do |start_time|
          if not start_time.nil?
            square = gen_black_square x: w, y: h
            square.zoom_x = 0
            sprites_to_dispose.append square
            square.x = x_pos
            square.y = y_pos
            animations += properties.map {|p| square.animate_property p, [start_time,0], [start_time+zoom_duration,1]}
          end
          y_pos += h
        end
        x_pos += w
      end
      super(sprites_to_dispose, *animations)
    end
  end

  class Snake_Squares < Square_Transition
    def initialize duration
      cx = 8
      cy = 6
      zoom_duration = 0.1
      time_offset = (duration-zoom_duration)/((cy/2 + 1)*cx)      
      squares = Array.new(cx){Array.new(cy)}

      snake_pattern = -> (x_pos, y_pos, x_dir, y_dir) do
        start_time = 0
        (cy/2).times do
          cx.times do
            squares[x_pos][y_pos] = start_time
            start_time += time_offset
            x_pos += x_dir
          end
        y_pos += y_dir
        x_dir *= -1
        x_pos += x_dir
        end
      end

      snake_pattern.call 0, 0, 1, 1
      snake_pattern.call cx-1, cy-1, -1, -1
      super duration, zoom_duration, squares, :zoom_x
    end
  end
 
  #=============================================================================
  # HGSS wild indoor day (origin=0)
  # HGSS wild indoor night (origin=3)
  # HGSS wild cave (origin=3)
  #=============================================================================
  class Diagonal_Bubble_TL < Square_Transition
    def self.play duration, cx: 8, cy: 6, invert: false
      zoom_duration = 0.1   
      squares = Array.new(cx){Array.new(cy)}
      diagonal_vec = Vector[cx-1,cy-1]
      cx.times do |i|
        cy.times do |j| 
          angle = Vector[i+1,j+1].angle_with diagonal_vec
          distance_on_diag = Math.cos(angle) * Vector[i,j].magnitude
          relative_distance = (invert ? diagonal_vec.magnitude - distance_on_diag : distance_on_diag)/diagonal_vec.magnitude
          squares[i][j] = duration * relative_distance
        end
      end
      super duration, zoom_duration, squares, :zoom_x, :zoom_y
    end 
  end

  class Diagonal_Bubble_BR < Diagonal_Bubble_TL
    def self.play duration, cx: 8, cy: 6
      super duration, cx: cx, cy: cy, invert: true 
    end
  end
end
