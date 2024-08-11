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
  @@sprites_to_update = []
  
  def self.register_sprite s
    @@sprites_to_update.append s
  end

  def self.unregister_sprite s
    @@sprites_to_update.delete s
  end

  def self.wait_until_all_finished skip: false, skippable: false, w_dispose: false
    while self.update_all_animations and (not skip or not skippable)
      Graphics.update
      Input.update
      skip = Input.press?Input::C
    end
    Graphics.update
    self.clean w_dispose: w_dispose
    return skip
  end
  
  def self.update_all_animations 
    sprite_remaining = false
    @@sprites_to_update.each do |s|
      s.update
      sprite_remaining |= (not s.finished)
    end
    return sprite_remaining
  end

  def self.clean w_dispose: false
    @@sprites_to_update.each do |s|
      s.clean w_dispose: w_dispose
    end
    @@sprites_to_update.clear
  end

  # Animation curves describe how a proberty changes over time.
  # Its points describe the value of the property at a fixed point in time 
  # and the interpolation method dictates how the property behaves between these points.
  # There are two implicite points, the first at (0,0) and the second at (duration,0)
  # If other values are needed, they can simply be overwritten
  class Animation_Curve
    
    attr_accessor :property_setter
    attr_reader :is_finished

    def initialize property_setter, duration, looping: false
      @property_setter = property_setter
      @looping = looping
      @is_finished = false
      @duration = duration
    end

    def interpolation runtime
      return 0
    end

    def apply runtime
      if @looping
        runtime = runtime % @duration 
      else
        runtime = runtime.clamp(0,@duration)
      end
      value = interpolation runtime
      @is_finished = @looping || runtime >= @duration
      return value
    end
  end


  
  class Linear_Animation < Animation_Curve
     
    def initialize property_setter, *points, looping: false
      @next_index = 0
      if points[0][0] != 0
        # If not explicitly set, start animation from value 0
        points.prepend [0,0]
      end
      points = points.sort {|x,y| x[0] <=> y[0]}
      @points = points
      super property_setter, @points[-1][0], looping: looping
    end

    def mirror
      # Mirror the points to create a seemless loop 
        # Convert to time spans before reversing
        relative_time_spans = (0..(@points.length-2)).map do |i|
          [@points[i+1][0]-@points[i][0],@points[i][1],@points[i+1][1]]
        end
        mirrored_time_spans = relative_time_spans + relative_time_spans.reverse.map {|p| [p[0],p[2],p[1]]}
        mirrored_time_stamps=[]
        
        # Convert back to absolute time stamps
        mirrored_time_stamps[0] = [0, @points[0][1]]
        (1..mirrored_time_spans.length).each do |i|
          mirrored_time_stamps[i] = [mirrored_time_stamps[i-1][0]+mirrored_time_spans[i-1][0],mirrored_time_spans[i-1][2]]
        end
        
        @points = mirrored_time_stamps
        @duration = @points[-1][0]
    end 

    def interpolation runtime
      p_1 = [nil,nil]
      p_2 = [nil,nil]
      mod_or_clamp = -> (x) {@looping ? (@next_index + x) % @points.length : (@next_index + x).clamp(0,@points.length-1)}
      previous_index = mod_or_clamp.call(-1)
      @points.length.times do |i| 
        if runtime <= @points[@next_index][0] and (@next_index==0 or runtime >= @points[previous_index][0])
          p_1 = @points[@next_index] 
          p_2 = @points[previous_index]
          break
        end
        @next_index = mod_or_clamp.call 1
        previous_index = mod_or_clamp.call(-1)
      end


      if p_1[0] == p_2[0]
        return p_2[1]
      end
      m = (p_2[1]-p_1[1])/(p_2[0]-p_1[0])
      b = p_1[1]-m*p_1[0]
      return m*runtime + b
    end      
  end

  class Sin_Animation < Animation_Curve   

    def initialize property_setter, duration, amplitude: 1, phase: 0, offset: 0, wave_length: 1, looping: false
      @amplitude = amplitude
      @phase = phase
      @offset = offset
      @wave_length = wave_length
      super property_setter, duration, looping: looping
    end

    def interpolation runtime
      return @amplitude * Math.sin(runtime * @wave_length + @phase) + @offset
    end
  end

  class Animated_Sprite < Sprite
    attr_reader :finished

    def initialize *args
     @curves = []
     @start_time = Graphics.time
     @finished = true
     super(*args)
    end
        
    def create_curve property_setter, *points, looping: false
      curve = Linear_Animation.new property_setter, *points, looping: looping 
      add_curve curve
    end

    def add_curve curve 
      if @curves.length == 0
        @start_time = Graphics.time
        Animation.register_sprite self
      end
      @finished = false
      @curves.append curve
      self.visible = true
    end
 
    def runtime
      return Graphics.time - @start_time
    end
    
    def update
      finished = true
      @curves.each do |c| 
        value = c.apply (runtime)
        call_setter c.property_setter, value
        finished = finished && c.is_finished
      end
      @finished = finished 
      super
    end

    def change_origin origin
      case origin
      when PictureOrigin::Center
        self.ox = self.src_rect.width / 2
        self.oy = self.src_rect.height / 2
      end
    end

    def dispose
      Animation.unregister_sprite self
      super
    end

    def clean w_dispose: false
      @curves.clear
      dispose if w_dispose
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
