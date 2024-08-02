module Animation 
  # Animation curves describe how a proberty changes over time.
  # Its points describe the value of the property at a fixed point in time 
  # and the interpolation method dictates how the property behaves between these points.
  # There are two implicite points, the first at (0,0) and the second at (duration,0)
  # If other values are needed, they can simply be overwritten
  class Animation_Curve
    
    attr_accessor :property_setter
    attr_reader :is_finished

    def initialize property_setter, interpolation, *points
      @property_setter = property_setter 
      @interpolation = method interpolation
      @points = [[0,0]]
      @is_finished = false
      # The next point, that happens after the last known runtime.
      # Don't access direcly, is updated through the getter.
      # This is used to prevent searching the entire array everytime.
      # Since the point array is always sorted, it is always sufficient to only look at the next point and only start seaching once that lies in the past   
      @next_index = 0
      points.each {|p| add_point p}
    end

    def add_point p
      # Insert somwhere into the middle, if there is a point later in time
      for i in 0..@points.length-1 do
        if p[0] <= @points[i][0]
          if p[0] == @points[i][0]
            # New value for defined time point => replace old
            @points[i] = p
          else
            @points.insert i,p
          end
          return
        end
      end
      # Append, p is latest point
      @points.append p
    end

    def next_point runtime
      if runtime <= @points[@next_index][0]
        return @points[@next_index]
      else
        # Update index, so we don't have to search the entire array later on
        # TODO Obviously fails, if more than one point slip into the past on one update
        @next_index = (@next_index+1).clamp(0,@points.length - 1)
        return @points[@next_index]
      end
    end

    def previous_point runtime
      next_point runtime
      index = (@next_index - 1).clamp(0,@points.length - 1)
      return @points[index] 
    end

    def apply runtime
      _next_point = next_point runtime
      _previous_point = previous_point runtime
      if runtime == _next_point[0]
        value = _next_point[1]
      else
        value = @interpolation.call _previous_point, _next_point, runtime
      end
      @is_finished = runtime >= @points[-1][0]
      return value
    end

    def linear_interpolation p_1, p_2, runtime
      # Clamp, this function is only meant for interpolating, not extrapolating.
      time_point = runtime.clamp p_1[0], p_2[0]
      m = (p_2[1]-p_1[1])/(p_2[0]-p_1[0])
      b = p_1[1]-m*p_1[0]
      return m*time_point + b 
    end 
  end

  class Animated_Sprite < Sprite
    @@sprites_to_update = []
    def self.update_animations
      # Copy, to not modify the array while iterating over it
      animations = @@sprites_to_update
      animations.each {|a| a.update}
      return (not @@sprites_to_update.empty?)
    end

    def self.wait_until_all_finished skip=false
      while self.update_animations and not skip
        Graphics.update
        Input.update
        skip = Input.press?Input::C
      end
      return skip
    end
    
    def create_curve property_setter, interpolation, *points
      curve = Animation_Curve.new property_setter, interpolation, *points
      add_curve curve
    end

    def add_curve curve 
      if @curves.length == 0
        @@sprites_to_update.append self
      end
      @curves.append curve
      self.visible = true
    end

    def initialize *args
     @curves = []
     @runtime = 0
     super(*args)
    end
    
    def update
      finished_curves = []
      @curves.each do |c| 
        value = c.apply @runtime
        call_setter c.property_setter, value
        finished_curves.append c if c.is_finished
      end
      finished_curves.each {|c| @curves.delete c}
      
      @runtime += Graphics.delta
      if not finished_curves.empty? and @curves.empty?
        # A curve finished and none is left. No need to update, untill a new curve is added
        @@sprites_to_update.delete self
        @runtime = 0
      end  
      super
    end

    private

    def call_setter setter, value
      # Unpack the property_setter.
      # If it is a symbol, it needs to be resolved
      if setter.is_a? Symbol
        method(setter).call value
      # If it is a method/proc, it needs a reference to this sprite
      else 
        setter.call self, value
      end
    end
  end
end
