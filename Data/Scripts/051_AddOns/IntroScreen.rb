#===============================================================================
#  New animated Title Screens for Pokemon Essentials
#    by Luka S.J.
#
#  Adds new visual styles to the Pokemon Essentials title screen, and animates
#  depending on the style selected
#===============================================================================
###SCRIPTEDIT1
# Config value for selecting title screen style
SCREENSTYLE = 1
# 1 - FR/LG
# 2 - R/S/E
class Scene_Intro

  alias main_old main

  def playIntroCinematic
    intro_sprite = Sprite.new
    intro_sprite.bitmap = Bitmap.new("Graphics/Pictures/Intro/INTRO.gif")
    pbBGMPlay("INTRO_music_cries")
    play_bitmaps_to_end intro_sprite.bitmap
    pbBGMStop
  end

  def main
    Graphics.transition(0)
    # Cycles through the intro pictures
    @skip = false

    #playIntroCinematic
    # Selects title screen style
    @screen = GenOneStyle.new
    # Plays the title screen intro (is skippable)
    @screen.intro

    # Creates/updates the main title screen loop
    self.update
    Graphics.freeze
  end

  def update
    ret = 0
    loop do
      Graphics.update
      Input.update
      if Input.press?(Input::DOWN) &&
        Input.press?(Input::B) &&
        Input.press?(Input::CTRL)
        ret = 1
        break
      end
      if Input.trigger?(Input::C)
        ret = 2
        break
      end
    end
    case ret
    when 1
      closeSplashDelete(scene, args)
    when 2
      closeTitle
    end
  end

  def closeTitle
    # Play Pokemon cry
    pbSEPlay("Absorb2", 100, 100)
    # Fade out
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    #clearTempFolder
    # initializes load screen
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end

  def closeTitleDelete
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes delete screen
    sscene = PokemonLoadScene.new
    sscreen = PokemonLoad.new(sscene)
    sscreen.pbStartDeleteScreen
  end

  def disposeTitle
    @screen.dispose
  end
end

module Animation
  require 'matrix' 
  # Animation curves describe how a proberty changes over time.
  # Its points describe the value of the property at a fixed point in time 
  # and the interpolation method dictates how the property behaves between these points.
  # There are two implicite points, the first at (0,0) and the second at (duration,0)
  # If other values are needed, they can simply be overwritten
  class Animation_Curve
        
    def initialize property_setter, interpolation
      @property_setter = property_setter
      @interpolation = method interpolation
      @points = [Vector[0,0]]
      # The next point, that happens after the last known runtime.
      # Don't access direcly, is updated through the getter.
      # This is used to prevent searching the entire array everytime.
      # Since the point array is always sorted, it is always sufficient to only look at the next point and only start seaching once that lies in the past   
      @next_index = 0   
    end

    def add_point p
      i = 0
      while p[0] < @points[i][0] do 
        i += 1
      end
      if p[0] == @points[i][0]
        # New value for defined time point => replace old
        @points[i] = p
      else
        # New time point. Insert after the first one earlier in time 
        @points.insert i+1, p
      end
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
      @property_setter.call value
    end

    def linear_interpolation p_1, p_2, runtime
      # Clamp, this function is only meant for interpolating, not extrapolating
      time_point = runtime.clamp p_1[0], p_2[0]
      m = (p_2[1]-p_1[1])/(p_2[0]-p_1[0])
      b = p_1[1]-m*p_1[0]
      return m*time_point + b 
    end 


  end
  

  class Animated_Sprite < Sprite
    attr_accessor :curves
    
    def initialize *args
     @curves = []
     @runtime = 0
     super(*args)
    end

    
    def update
      curves.each {|c| c.apply @runtime}
      @runtime += Graphics.delta
      self.visible = true
      super
    end

  end
end


#===============================================================================
# Styled to look like the FRLG games
#===============================================================================
class GenOneStyle
  require 'matrix'

    
  def initialize

    @sprites = {}
    @z_min = 0
    @z_max = 1

    Kernel.pbDisplayText("Keybindings: F1", 80, 0, 99999)
    Kernel.pbDisplayText("Version " + Settings::GAME_VERSION_NUMBER, 254, 308, 99999)

    @maxPoke = 140 #1st gen, pas de legend la premiere fois, graduellement plus de poke
    @customPokeList = getCustomSpeciesList(false)
    #Get random Pokemon (1st gen orandPokenly, pas de legend la prmeiere fois)

    # sound file for playing the title screen BGM
    bgm = "Pokemon Red-Blue Opening"
    @skip = false
    # speed of the effect movement
    @disposed = false
    pbBGMPlay(bgm)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    #@sprites = {}

    load_sprites
  end
  
  def load_sprites
    randPoke = getRandomCustomFusionForIntro(true, @customPokeList, @maxPoke)
    [
      # Background Stuff
      [:bg, "Graphics/Titles/gen1_bg"],
      [:bars, "Graphics/Titles/gen1_bars"],
      [:logo,"Graphics/Titles/pokelogo"],
      # The fusing pokemon
      [:poke, (get_unfused_sprite_path randPoke[0])],
      [:poke2, (get_unfused_sprite_path randPoke[1])],
      [:fpoke, (get_fusion_sprite_path randPoke[0], randPoke[1])]
    ].each do |name_path| 
      name, path = name_path
      @sprites[name] = Animation::Animated_Sprite.new(@viewport) 
      @sprites[name].bitmap = pbBitmap path
      @sprites[name].visible = false
    end
  end

  def intro
    Graphics.update
    
    slide = Animation::Animation_Curve.new ->(v){@sprites[:bg].x=v}, :linear_interpolation

    slide.add_point Vector[0,-Graphics.width]
    slide.add_point Vector[0.2,0]
    @sprites[:bg].curves.append slide

    while true
      @sprites[:bg].update
      #binding.break
      Graphics.update
    end

    ## Turn the opacity of two unfused pokemon slowly up
    #poke1_opacity = animate_bitmap_blit @bitmaps[:poke], bg_rect, 64,
    #  x_start: 400, y_start: 75,
    #  opacity_start: 0, opacity_end: 256
    #poke1_opacity.flash(nil,100)
    #poke2_opacity = animate_bitmap_blit @bitmaps[:poke2], bg_rect, 64,
    #  x_start: -150, y_start: 75,
    #  opacity_start: 0, opacity_end: 256
    #play_bitmaps_to_end poke1_opacity.bitmap, poke2_opacity.bitmap
   
    ## Background image slides in from left screen border
    #bg_slide_in = animate_bitmap_blit @bitmaps[:bg], bg_rect, 8,
    #  x_start: -bg_rect.width, x_end: 0, on_top: false
    #play_bitmaps_to_end bg_slide_in.bitmap

    ## Bars slide in from the right screen border
    #bars_slide_in = animate_bitmap_blit @bitmaps[:bars], bg_rect, 8,
    #  x_start: bg_rect.width, x_end: 0
    #play_bitmaps_to_end bars_slide_in.bitmap

    ## Logo appears and goes form purly white to its real colors
    #logo

  end

  def getFusedPath(randpoke1, randpoke2)
    path = rand(2) == 0 ? get_fusion_sprite_path(randpoke1, randpoke2) : get_fusion_sprite_path(randpoke2, randpoke1)
    if Input.press?(Input::RIGHT)
      path = get_fusion_sprite_path(randpoke2, randpoke1)
    elsif Input.press?(Input::LEFT)
      path = get_fusion_sprite_path(randpoke1, randpoke2)
    end
    return path
  end

end

def dispose
  Kernel.pbClearText()
  pbFadeOutAndHide(@sprites)
  pbDisposeSpriteHash(@sprites)
  @viewport.dispose
  @disposed = true
end

def disposed?
  return @disposed
end

def play_bitmaps_to_end *bitmaps
  bitmaps.each do |bitmap|
    bitmap.looping = false # Just to be sure
    bitmap.play
  end
 
  at_least_one_playing = ->() do
    bitmaps.reduce(false) {|sum,bitmap| sum or bitmap.playing}
  end

  while at_least_one_playing.call and not @skip do
    Graphics.update
    Input.update
    if Input.press?(Input::C)
      @skip = true
    end
  end
end

