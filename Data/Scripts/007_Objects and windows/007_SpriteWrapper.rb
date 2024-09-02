#===============================================================================
# SpriteWrapper is a class which wraps (most of) Sprite's properties.
#===============================================================================
class SpriteWrapper
  def initialize(viewport = nil)
    @sprite = Sprite.new(viewport)
  end

  def dispose
    @sprite.dispose;
  end

  def disposed?
    return @sprite.disposed?;
  end

  def viewport
    return @sprite.viewport;
  end

  def flash(color, duration)
    ; return @sprite.flash(color, duration);
  end

  def update
    return @sprite.update;
  end

  def x
    @sprite.x;
  end

  def x=(value)
    ; @sprite.x = value;
  end

  def y
    @sprite.y;
  end

  def y=(value)
    ; @sprite.y = value;
  end

  def bitmap
    @sprite.bitmap;
  end

  def bitmap=(value)
    ; @sprite.bitmap = value;
  end

  def src_rect
    @sprite.src_rect;
  end

  def src_rect=(value)
    ; @sprite.src_rect = value;
  end

  def visible
    @sprite.visible;
  end

  def visible=(value)
    ; @sprite.visible = value;
  end

  def z
    @sprite.z;
  end

  def z=(value)
    ; @sprite.z = value;
  end

  def ox
    @sprite.ox;
  end

  def ox=(value)
    ; @sprite.ox = value;
  end

  def oy
    @sprite.oy;
  end

  def oy=(value)
    ; @sprite.oy = value;
  end

  def zoom_x
    @sprite.zoom_x;
  end

  def zoom_x=(value)
    ; @sprite.zoom_x = value;
  end

  def zoom_y
    @sprite.zoom_y;
  end

  def zoom_y=(value)
    ; @sprite.zoom_y = value;
  end

  def angle
    @sprite.angle;
  end

  def angle=(value)
    ; @sprite.angle = value;
  end

  def mirror
    @sprite.mirror;
  end

  def mirror=(value)
    ; @sprite.mirror = value;
  end

  def bush_depth
    @sprite.bush_depth;
  end

  def bush_depth=(value)
    ; @sprite.bush_depth = value;
  end

  def opacity
    @sprite.opacity;
  end

  def opacity=(value)
    ; @sprite.opacity = value;
  end

  def blend_type
    @sprite.blend_type;
  end

  def blend_type=(value)
    ; @sprite.blend_type = value;
  end

  def color
    @sprite.color;
  end

  def color=(value)
    ; @sprite.color = value;
  end

  def tone
    @sprite.tone;
  end

  def tone=(value)
    ; @sprite.tone = value;
  end

  def viewport=(value)
    return if self.viewport == value
    bitmap = @sprite.bitmap
    src_rect = @sprite.src_rect
    visible = @sprite.visible
    x = @sprite.x
    y = @sprite.y
    z = @sprite.z
    ox = @sprite.ox
    oy = @sprite.oy
    zoom_x = @sprite.zoom_x
    zoom_y = @sprite.zoom_y
    angle = @sprite.angle
    mirror = @sprite.mirror
    bush_depth = @sprite.bush_depth
    opacity = @sprite.opacity
    blend_type = @sprite.blend_type
    color = @sprite.color
    tone = @sprite.tone
    @sprite.dispose
    @sprite = Sprite.new(value)
    @sprite.bitmap = bitmap
    @sprite.src_rect = src_rect
    @sprite.visible = visible
    @sprite.x = x
    @sprite.y = y
    @sprite.z = z
    @sprite.ox = ox
    @sprite.oy = oy
    @sprite.zoom_x = zoom_x
    @sprite.zoom_y = zoom_y
    @sprite.angle = angle
    @sprite.mirror = mirror
    @sprite.bush_depth = bush_depth
    @sprite.opacity = opacity
    @sprite.blend_type = blend_type
    @sprite.color = color
    @sprite.tone = tone
  end
end

#===============================================================================
# Sprite class that maintains a bitmap of its own.
# This bitmap can't be changed to a different one.
#===============================================================================
class BitmapSprite < SpriteWrapper
  def initialize(width, height, viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(width, height)
    @initialized = true
  end

  def bitmap=(value)
    super(value) if !@initialized
  end

  def dispose
    self.bitmap.dispose if !self.disposed?
    super
  end
end

#===============================================================================
#
#===============================================================================
class AnimatedSprite < SpriteWrapper
  attr_reader :frame
  attr_reader :framewidth
  attr_reader :frameheight
  attr_reader :framecount
  attr_reader :animname
  attr_reader :playing

  def initializeLong(animname, framecount, framewidth, frameheight, frameskip)
    bitmap = (animname.is_a? String) ? (Bitmap.new animname) : (animname)
    if framewidth == 0 or frameheight == 0
      framewidth = bitmap.width / 4
      frameheight = bitmap.height
    end
    @framewidth = framewidth
    @frameheight = frameheight
      
    raise _INTL("Frame width is 0") if framewidth == 0
    raise _INTL("Frame height is 0") if frameheight == 0
    if bitmap.width % framewidth != 0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame width ({2}) [Bitmap={3}]",
                  bitmap.width, framewidth, animname)
    end
    if bitmap.height % frameheight != 0
      raise _INTL("Bitmap's height ({1}) is not a multiple of frame height ({2}) [Bitmap={3}]",
                  bitmap.height, frameheight, animname)
    end
    
    framesperrow = bitmap.width / framewidth
    
    bitmap_combined = nil
    framecount.times do |i|
      rect = Rect.new i % framesperrow * framewidth, i / framesperrow * frameheight, framewidth, frameheight
      bitmap_cutout = Bitmap.new framewidth, frameheight
      bitmap_cutout.blt 0, 0, bitmap, rect
      if i == 0
        bitmap_combined = bitmap_cutout
      else
        bitmap_combined.add_frame bitmap_cutout
      end
    end
    bitmap_combined.frame_rate = 40.0 / frameskip
    if bitmap_combined.animated?
      bitmap_combined.playing = true
    end
 
    self.bitmap = bitmap_combined
  end

  

  def initialize(*args)
    if args.length == 1
      raise "Short initialization is deprecated"
    else
      super(args[5])
      initializeLong(args[0], args[1], args[2], args[3], args[4])
    end
  end

  def self.create(animname, framecount, frameskip, viewport = nil)
    return self.new animname, framecount, 0, 0, frameskip
  end

  def dispose
    return if disposed?
    self.bitmap.dispose
    @animbitmap = nil
    super
  end

  def playing?
    return @playing
  end

  def frame=(value)
  end

  def start
    @playing = true 
  end

  alias play start

  def stop
    @playing = false
  end

  def reset 
  end

end

#===============================================================================
# Displays an icon bitmap in a sprite. Supports animated images.
#===============================================================================
class IconSprite < SpriteWrapper
  attr_reader :name
  def initialize(*args)
    if args.length == 0
      super(nil)
      self.bitmap = nil
    elsif args.length == 1
      super(args[0])
      self.bitmap = nil
    elsif args.length == 2
      super(nil)
      self.x = args[0]
      self.y = args[1]
    else
      super(args[2])
      self.x = args[0]
      self.y = args[1]
    end
    @name = ""
    @_iconbitmap = nil
  end

  def dispose
    clearBitmaps()
    super
  end

  # Sets the icon's filename.  Alias for setBitmap.
  def name=(value)
    setBitmap(value)
  end

  def setBitmapDirectly(bitmap)
    oldrc = self.src_rect
    clearBitmaps()
    @name = ""
    return if bitmap == nil
    @_iconbitmap = bitmap
    # for compatibility
    #
    self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
    self.src_rect = oldrc
  end

  def setColor(r = 0, g = 0, b = 0, a = 255)
    @_iconbitmap.pbSetColor(r,g,b,a)
  end

  # Sets the icon's filename.
  def setBitmap(file, hue = 0)
    oldrc = self.src_rect
    clearBitmaps()
    @name = file
    return if file == nil
    if file != ""
      @_iconbitmap = AnimatedBitmap.new(file, hue)
      # for compatibility
      self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
      self.src_rect = oldrc
    else
      @_iconbitmap = nil
    end
  end

  def getBitmap
    return @_iconbitmap
  end

  def clearBitmaps
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
  end

  def update
    super
    return if !@_iconbitmap
    @_iconbitmap.update
    if self.bitmap != @_iconbitmap.bitmap
      oldrc = self.src_rect
      self.bitmap = @_iconbitmap.bitmap
      self.src_rect = oldrc
    end
  end


end

#===============================================================================
# Old GifSprite class, retained for compatibility
#===============================================================================
class GifSprite < IconSprite
  def initialize(path)
    super(0, 0)
    setBitmap(path)
  end
end

#===============================================================================
# SpriteWrapper that stores multiple bitmaps, and displays only one at once.
#===============================================================================
class ChangelingSprite < SpriteWrapper
  def initialize(x = 0, y = 0, viewport = nil)
    super(viewport)
    self.x = x
    self.y = y
    @bitmaps = {}
    @currentBitmap = nil
  end

  def addBitmap(key, path)
    @bitmaps[key].dispose if @bitmaps[key]
    @bitmaps[key] = AnimatedBitmap.new(path)
  end

  def changeBitmap(key)
    @currentBitmap = @bitmaps[key]
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end

  def dispose
    return if disposed?
    for bm in @bitmaps.values;
      bm.dispose;
    end
    @bitmaps.clear
    super
  end

  def update
    return if disposed?
    for bm in @bitmaps.values;
      bm.update;
    end
    self.bitmap = (@currentBitmap) ? @currentBitmap.bitmap : nil
  end
end



module Animation
  class Animation
    attr_reader :duration
    attr_reader :loop_duration
    attr_reader :repeats
    attr_reader :start_time
    attr_reader :started
    attr_reader :name # Only for easing debugging
    attr_accessor :finished

    def initialize repeats=1, name: "".freeze
      if repeats > 0
        @repeats = repeats
      else
        @repeats = Float::INFINITY
      end
      @name = name
      @finished = false
      @times_played = 0
    end

    def started time
      return time >= @start_time
    end

    def mark_start time_stamp
      return false if @start_time
      @start_time = time_stamp
      return true 
    end

    def update time: Graphics.time
      return if @finished
      mark_start time
      n_time = normalize_time time
      _update n_time
      if not(running n_time) && finish_conditions
        @finished = true
        
        if @times_played+1 < @repeats
          @times_played += 1
          on_loop
        end
      end
      return not(@finished)
    end

    def to_s
      return @name=="" ? super : "#{@name}( start: #{@start_time}, dur: #{@duration})" 
    end

    # Overwrite to reset everything that needs too on the beginning of a new loop
    def on_loop
      @finished = false
    end


    private

    # Overwrite to implement actual animation
    def _update n_time
    end
    
    # Overwrite to set additional conditions that need to be fullfilled, in order to set the @finished variable
    def finish_conditions
      return true
    end
    
    # The difference between @finshed and running is that running only looks at the time and determines if the given timepoint lies in start to duration.
    # @finished, on the other hand, is set when the animation was updated at least once, while running determined that it should no longer run.
    # That's also the reson why running is private and finished isn't.
    # All extern checks that want to determine if the animation should run or not must use (not) animation.finished, to ensure that the animation was executed at least once at the last time point. 
    def running time
      # Delta check because multilple floats get summed up for time
      return time < @duration - 0.0001
    end

    def normalize_time time
      # Otherwise infinte loops don't work. 0 * inf is NaN, not 0
      if @duration.finite?
        return time - @start_time - @duration * @times_played
      else
        return time - @start_time
      end
    end
  end

  class Property < Animation 
    def initialize setter, curve, getter: nil, repeats: 1
      @setter = setter
      @curve = curve
      @getter = getter
      @duration = curve.duration
      @loop_duration = @duration * repeats
      # If a getter for the porperty is given, it is animated relativly. 
      if getter
        # Used to disect the property p into p=last_value+extern_change+animation
        current_value = getter.call
        @last_property_value = current_value
        @last_property_set = current_value
      end
      super repeats
    end

    def to_s
      @name = @setter.source_location
      super
    end

    private
    
    def _update n_time
      n_time = n_time.clamp(0, @duration)
      value = @curve.gen_value (n_time)
      if @getter
        current_value = @getter.call
        extern_change = current_value - @last_property_set
        value += @last_property_value + extern_change
        @last_property_value += extern_change
        @setter.call value
        @last_property_set = @getter.call
      else
        @setter.call value
      end
    end
  end

  class Container < Animation
    attr_reader :animations

    def initialize *animations, parallel: false, repeats: 1, name: "".freeze
      super repeats, name: name
      @animations = animations
      @parallel = parallel
      @last_animation = nil
      if not parallel
        @first_anim_to_play = 0 
      end
    end

    def add *animations
      if @started
        # TODO only raise when debug is active, to avoid unnecesarry crashes
        raise StandardError.new "Can't add animation. Playing has already started."
      else
        @animations += animations 
      end
    end

    def play_and_finish  
      Graphics.update
      while update
        Graphics.update
        user_skips?
      end
      Graphics.update
    end

    def mark_start time
      if !super || @animations.empty?
        return false
      end
      @animations.each_with_index{|a,i| 
        start = calc_start i
        a.mark_start start
      }
      # Calculate our own duration
      if @parallel
        @last_animation = @animations.max {|a,b| a.loop_duration <=> b.loop_duration}
      else
        @last_animation = @animations[-1]
      end
      @duration = @last_animation.start_time + @last_animation.loop_duration
      @loop_duration = @duration * @repeats
    end

    def to_s
      info = super
      info += "{\n"
      @animations.each {|a| info += "[" + a.to_s + "]" }
      info += "\n}"
    end

    def dispose
      @animations.each {|a| a.dispose}
      @animations.clear
      super
    end

    private

    def _update n_time
      if @parallel
        @animations.each {|a| a.update time: n_time}
      else
        # Find first anim that isn't finished
        i = @first_anim_to_play
        should_play = -> (i) {@animations[i].started n_time and not @animations[i].finished}
        @animations.each do
          if should_play.call i
            break
          else
            i = (i + 1) % @animations.length
          end
        end
        @first_anim_to_play = i 
        # Update all animations that already started and that are after the first not finished one
        @animations.each do 
          if not should_play.call i
            break
          else
            @animations[i].update time: n_time
            i = (i + 1) % @animations.length
          end
        end 
      end
    end

    def on_loop
      super
      @animations.each {|a| a.on_loop}
    end

    def finish_conditions
      # Normally, all other animations should already be finished once the last animation did.
      # But just to be sure, once the last finished, all others are also checked.
      return @last_animation.finished && @animations.find{|a| not a.finished}.nil?
    end

    def calc_start i
      if @parallel
        return 0
      else
        if i == 0
          return 0
        else
          prev_a = @animations[i-1]
          return prev_a.start_time + prev_a.loop_duration
        end
      end
    end

    # While a container is supposed to have an easy and predictable controlflow, skipping animations is a common usecase, in example in the intro sequence or in textboxes.
    def user_skips?
      Input.update
      skip = (skip_keys.map {|k| Input.press?k}).reduce false, :|
      skip_reaction if skip
    end

    # This method can be overwritten to implement individual reactions for skipping.
    # It is automatically called when the user presses a key defined in skip_keys while an animation plays,
    def skip_reaction
    end

    def skip_keys
      return [Input::C]
    end
  end

  class PointBased < Container
    def initialize setter, *points, interpolation: Value_Curves::Linear, repeats: 1
      if not points[0].is_a? Array
        animations = [Property.new(setter, Value_Curves::Constant.new(points[0]), repeats: repeats)] 
      else
        points.sort! {|p1,p2| p1[0] <=> p2[0]}
        points.insert 0, [0,0] if points[0][0] != 0 
        animations = []
        points.each_cons(2)do |p1,p2|
          x1,x2 = p1[0],p2[0]
          y1,y2 = p1[1],p2[1]
          # Normalize to startime 0
          animations.append Property.new(setter, interpolation.new([0,y1],[x2-x1,y2]), repeats: repeats)
        end
      end
      super(*animations, repeats: repeats)
    end
  end

  module Value_Curves
    # A curve, that generates a value for a given runtime.
    # The runtime has to be normaized, i.e. at runtime 0 the corresponding animation starts.
    class Curve
      attr_reader :duration
      
      def initialize duration
        @duration = duration
      end

      def gen_value runtime
        return gen_value_implementation runtime.clamp(0,@duration)
      end
      
      private
      # Overwrite 
      def gen_value_implementation
      end
    end

    class Constant < Curve
      def initialize value
        @value = value
        super 0
      end

      private
      def gen_value_implementation runtime
        return @value
      end
    end
    
    # A curve defined by two value pairs
    # E.g., a linear function definde by start and end point
    class Interpolation < Curve
      def initialize point1, point2
        @x1, @y1 = point1
        @x2, @y2 = point2
        super @x2
      end
    end
    
    # Uses a function of the form f(x) = a*x^2+b.
    # Therefore, only two points must be specified
    class Quadratic_Simple < Interpolation
      def initialize *args
        super
        @a = (@y2 - @y1) / (@x2**2 - @x1**2)
        @b = @y1 - @a*@x1**2
      end

      private
      def gen_value_implementation runtime
        return @a*runtime**2+@b
      end
    end

    class Linear < Interpolation
      def initialize *args
        super
        if @x1 != @x2
          @m = (@y2-@y1)/(@x2-@x1)
        else
          @m = 1
        end
        @b = @y1-@m*@x1
      end

      private
      def gen_value_implementation runtime
        return @m*runtime + @b
      end
    end

    class Sinus < Curve

      def initialize duration, amplitude: 1, phase: 0, offset: 0, wave_length: 1
        @amplitude = amplitude
        @phase = phase
        @offset = offset
        @wave_length = wave_length
        super property_setter, duration
      end

      def interpolation runtime, looping
        return @amplitude * Math.sin(runtime * @wave_length + @phase) + @offset
      end
    end 
  end

  module Implementations
    class Animated_Sprite < Sprite
      
      attr_reader :animations
      
      def initialize *args, parallel: false
        @animations = Container.new parallel: parallel
        super(*args)
      end
      
      def animate_property property, *points, interpolation: Value_Curves::Linear, relativ: false, repeats: 1
        setter = gen_setter property
        getter = gen_getter property if relativ
        return PointBased.new setter, *points, interpolation: interpolation, repeats: repeats
      end

      def update
        @animations.update
      end

      def finished
        return @animations.finished
      end

      def change_origin origin
        case origin
        when PictureOrigin::Center
          self.ox = self.src_rect.width / 2
          self.oy = self.src_rect.height / 2
        end
      end

      private

      def gen_setter property
        case property
        when :tone
          setter = ->(c){self.tone = Tone.new c, c, c}
        when :color
          setter = ->(c){self.color = Color.new c, c, c}
        else
          setter = method (property.to_s + "=").to_sym
        end
        return setter
      end

      def gen_getter property
        case property
        when :Tone
          getter = ->(){return self.Tone.red}
        when :Color
          getter = ->(){return self.Color.red}
        else
          getter = method property
        end
        return getter
      end

    end
  end
end
