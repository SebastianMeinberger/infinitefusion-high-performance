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
  def playIntroCinematic
    intro_sprite = Sprite.new
    intro_sprite.bitmap = Bitmap.new("Graphics/Pictures/Intro/INTRO")
    14.downto(1).each do |i|
      frame = Bitmap.new(sprintf "Graphics/Pictures/Intro/INTRO-%03d", i)
      intro_sprite.bitmap.add_frame frame, 0
    end
    pbBGMPlay("INTRO_music_cries")
    intro_sprite.bitmap.looping = false
    intro_sprite.bitmap.play
    while intro_sprite.bitmap.playing and not Input.press?(Input::C) do
      Graphics.update
      Input.update
    end
    pbBGMStop
  end
 
  def main
    Graphics.transition(0)
    #playIntroCinematic
    # Selects title screen style
    @screen = GenOneStyle.new
    # Plays the title screen intro (is skippable)
    @screen.play_intro
    closeTitle
    Graphics.freeze
  end
 
  def closeTitle
    # Play Pokemon cry
    pbSEPlay("Absorb2", 100, 100)
    # Fade out
    pbBGMStop(1.0)
    # disposes current title screen
    @screen.dispose 
    # initializes load screen
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end
end



#===============================================================================
# Styled to look like the FRLG games
#===============================================================================

class Intro_Anim_Container < Animation::Container
  private
  def skip_reaction
    @finished = true
  end
end

class GenOneStyle
  def initialize
    @sprites = {}
    @maxPoke = 140 #1st gen, pas de legend la premiere fois, graduellement plus de poke
    @customPokeList = getCustomSpeciesList(false)
    #Get random Pokemon (1st gen orandPokenly, pas de legend la prmeiere fois)
    @disposed = false
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998

    Kernel.pbDisplayText("Keybindings: F1", 80, 0, 99999)
    Kernel.pbDisplayText("Version " + Settings::GAME_VERSION_NUMBER, 254, 308, 99999)
    pbBGMPlay("Pokemon Red-Blue Opening")
    
    # Load Background stuff
    load_sprites(
      [:bg, "Graphics/Titles/gen1_bg", -Graphics.width, 0],
      [:bars, "Graphics/Titles/gen1_btars", Graphics.width, 0],
      [:logo,"Graphics/Titles/pokelogo", 50, -20]
    )
    @sprites[:logo].visible = false
    # Load two pokemon, that will fuse
    load_forground_pokemon
  end
  
  def load_sprites *sprites
    sprites.each do |sprite_data| 
      name, path, x, y = sprite_data
      if @sprites[name]
        s = @sprites[name]
      else
        s = @sprites[name] = Animation::Implementations::Animated_Sprite.new @viewport
      end
      s.x = x if x
      s.y = y if y
      s.bitmap = pbBitmap path
      s.visible = true
    end
  end

  def load_forground_pokemon
    randPoke = getRandomCustomFusionForIntro(true, @customPokeList, @maxPoke)
    load_sprites(
      [:poke, (get_unfused_sprite_path randPoke[0]), 400, 75],
      [:poke2, (get_unfused_sprite_path randPoke[1]), -150, 75],
      [:fpoke, (getFusedPath randPoke[0], randPoke[1]), 125, 75]
    )
    @sprites[:fpoke].visible = false
    [:poke, :poke2].map {|p|  #@sprites[p].opacity = 0
                              @sprites[p].tone = Tone.new(0,0,0)}
  end

  def play_intro 
    # The Intro_Anim_Container implements a skip reaction, that skips the entire Intro sequenc on pressing Input::C
    final_animation = Intro_Anim_Container.new
    poke, poke2, fpoke, bg, bars, logo = [:poke, :poke2, :fpoke, :bg, :bars, :logo].map {|s| @sprites[s]} 
    
    # Turn the opacity of the two unfused pokemon slowly up.
    animation = Animation::Container.new parallel: true
    animation.add(
      *[poke,poke2].map{|p| p.animate_property :opacity, [1.6,255]}
    )
    final_animation.add animation
    # Background slides in from left, bars slide in from right.
    # Then, the logo appears and plays a shine effect.
    animation = Animation::Container.new name: "BG Stuff"
    animation.add(
            #bars.animate_property(:x, [0, Graphics.width], [0.2,0]),
      bg.animate_property(:x, [0, -Graphics.width],[0.2,0]),
      logo.animate_property(:visible, true),
      logo.animate_property(:tone, [0,255], [0.4,0]),
      
    )
    final_animation.add animation

    # Wrap the last animations into an additional container, that loops infinitly
    animation_loop = Animation::Container.new repeats: Float::INFINITY, name: "Loop"

    # Both pokemon slide towards eachother
    # 6 seconds for the first 2/3, the double speed => 1.5 seconds for last 1/3
    movement = [[0,0], [6,(poke2.x-poke.x)/3], [7.5,(poke2.x-poke.x)/2]]
    # The Pokemon start to shine, when accelerating for the last 1/3 of the way
    shine = [[6,0], [7.5,255]]
    animation = Animation::Container.new parallel: true
    animation.add(
      # Move
      poke.animate_property(:x, *movement.map {|p| [p[0],poke.x + p[1]]}),
      poke2.animate_property(:x, *movement.map {|p| [p[0],poke2.x - p[1]]}),
      # Shine
      *[poke,poke2].map {|p| p.animate_property :tone, *shine}
    )
    animation_loop.add animation
     
    # Reveal fusion
    animation = Animation::Container.new parallel: true
    animation.add(
        *[poke,poke2].map {|p| p.animate_property :visible, false},
        fpoke.animate_property(:visible, true),
        fpoke.animate_property(:tone, [0,255], [0.2,0], [3,0])
    )
    animation_loop.add animation

    # Reload pokemon, so loop begins with new ones 
    animation = Animation::Container.new
    animation.add(
      Animation::Property.new(->(_){
        load_forground_pokemon
        # one graphics update with multipler 0, to prevent lag through the potentially long loading time of poke sprites
        Graphics.time_multiplier = 0
        Graphics.update
        Graphics.time_multiplier = 1
      }, Animation::Value_Curves::Constant.new(nil)),
    )
    animation_loop.add animation
    final_animation.add animation_loop

    final_animation.play_and_finish
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

  def dispose
    Kernel.pbClearText()
    #pbFadeOutAndHide(@sprites)
    @sprites.each_value {|s| s.dispose}
    @viewport.dispose
    @disposed = true
  end
end


def disposed?
  return @disposed
end
