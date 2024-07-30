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

#===============================================================================
# Styled to look like the FRLG games
#===============================================================================
class GenOneStyle
    
  def initialize

    @bitmaps = {}
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
    @sprites = {}

    load_bitmaps
  end
  
  def interpolate_bitmap_blit_params bitmap, size_rect, number_frames, x_start, x_end, y_start, y_end, opacity_start, opacity_end, frame
    new_frame = Bitmap.new(size_rect.width, size_rect.height)
  
    x_pos = interpolate_l x_start, x_end, number_frames, frame
    y_pos = interpolate_l y_start, y_end, number_frames, frame
    opacity = interpolate_l opacity_start, opacity_end, number_frames, frame

    return new_frame.blt x_pos, y_pos, bitmap, size_rect, opacity
  end

  def interpolate_l start_val, end_val, number_frames, frame 
    return start_val + frame * (end_val - start_val)/number_frames
  end
  
  def animate_bitmap_blit bitmap, size_rect, number_frames, x_start: 0, x_end: x_start, y_start: 0, y_end: y_start, opacity_start: 255, opacity_end: 255, on_top: true
    
    # Send parameters relevant to interpolation to interpolation function
    delegate = ->(i) {interpolate_bitmap_blit_params bitmap, size_rect, number_frames, x_start, x_end, y_start, y_end, opacity_start, opacity_end, i}

    # Create first frame, so the rest can be attached to it
    animation = delegate.call 0 

    # Create remaining frames and attach to first
    for i in 1..number_frames do
      new_frame = delegate.call i 
      animation.add_frame new_frame
    end

    # Set animation properties
    animation.frame_rate = 20

    # Wrap into Sprite
    sprite = Sprite.new(@viewport)
    sprite.bitmap = animation
    if on_top
      sprite.z = @z_max
      @z_max += 1
    else
      sprite.z = @z_min
      @z_min -= 1
    end

    return sprite
   end
  
  def load_bitmaps
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
    ].each do |bitmap| 
      @bitmaps[bitmap[0]] = pbBitmap bitmap[1]
    end
  end

  def intro 
    bg_rect = @bitmaps[:bg].rect
    # Turn the opacity of two unfused pokemon slowly up
    poke1_opacity = animate_bitmap_blit @bitmaps[:poke], bg_rect, 64,
      x_start: 400, y_start: 75,
      opacity_start: 0, opacity_end: 256
    poke1_opacity.flash(nil,100)
    poke2_opacity = animate_bitmap_blit @bitmaps[:poke2], bg_rect, 64,
      x_start: -150, y_start: 75,
      opacity_start: 0, opacity_end: 256
    play_bitmaps_to_end poke1_opacity.bitmap, poke2_opacity.bitmap
   
    # Background image slides in from left screen border
    bg_slide_in = animate_bitmap_blit @bitmaps[:bg], bg_rect, 8,
      x_start: -bg_rect.width, x_end: 0, on_top: false
    play_bitmaps_to_end bg_slide_in.bitmap

    # Bars slide in from the right screen border
    bars_slide_in = animate_bitmap_blit @bitmaps[:bars], bg_rect, 8,
      x_start: bg_rect.width, x_end: 0
    play_bitmaps_to_end bars_slide_in.bitmap

    # Logo appears and goes form purly white to its real colors
    logo

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

