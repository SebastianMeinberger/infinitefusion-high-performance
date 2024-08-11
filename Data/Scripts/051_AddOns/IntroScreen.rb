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
    playIntroCinematic
    # Selects title screen style
    @screen = GenOneStyle.new
    # Plays the title screen intro (is skippable)
    @screen.intro
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
    load_sprites [:bg, "Graphics/Titles/gen1_bg"],
      [:bars, "Graphics/Titles/gen1_bars"],
      [:logo,"Graphics/Titles/pokelogo"]
    # Load two pokemon, that will fuse
    load_forground_pokemon
  end
  
  def load_sprites *sprites
    sprites.each do |name_path| 
      name, path = name_path
      if not @sprites[name].nil?
        @sprites[name].dispose
      end
      @sprites[name] = Animation::Animated_Sprite.new(@viewport) 
      @sprites[name].bitmap = pbBitmap path
      @sprites[name].visible = false
    end
  end

  def load_forground_pokemon
    randPoke = getRandomCustomFusionForIntro(true, @customPokeList, @maxPoke)
    load_sprites [:poke, (get_unfused_sprite_path randPoke[0])],
      [:poke2, (get_unfused_sprite_path randPoke[1])],
      [:fpoke, (getFusedPath randPoke[0], randPoke[1])]
    @sprites[:poke].x = 400
    @sprites[:poke2].x = -150
    @sprites[:poke].y = @sprites[:poke2].y = 75 
  end

  def intro 
    Graphics.update
    skip = false
    wait_all = ->() {skip = Animation::Animated_Sprite.wait_until_all_finished skip: skip}
    
    # Turn the opacity of the two unfused pokemon slowly up. 
    curve = Animation::Linear_Animation.new :opacity=, 
      [1.6,255]
    @sprites[:poke].add_curve curve
    @sprites[:poke2].add_curve curve 
    
      
    wait_all.call

    # Background image slides in from left screen border
    @sprites[:bg].create_curve :x=,
        [0,-Graphics.width],
        [0.2,0]

    wait_all.call

    # Bars slide in from the right screen border
    @sprites[:bars].create_curve :x=,
      [0,Graphics.width],
      [0.2,0]

    wait_all.call
       
    # Logo appears and goes from purly white to its real colors
    ->(l=@sprites[:logo]) {
      l.x, l.y = 50, -20 
      l.create_curve -> (o,v){o.tone = Tone.new v, v, v},
      [0,255], # 255 on all color channels of tone => Sprite color is shifted to 100% white
      [0.4,0] # all color channels empty => Sprite color remains unaltered
    }.call

    wait_all.call
    
    while not skip do
      # If not updated, the sliding can lag, depending on how long the download of the sprites took
      Graphics.update
      # Both pokemon slide towards eachother
      p1_x = @sprites[:poke].x
      p2_x = @sprites[:poke2].x
      dir_vec = (p2_x - p1_x)
      @sprites[:poke].create_curve :x=,
        [0,p1_x],
        [6, p1_x + dir_vec/3.0], # 6 seconds for the first 2/3
        [7.5, p1_x + dir_vec/2.0] # double speed => 1.5 seconds for last 1/3
      @sprites[:poke2].create_curve :x=,
        [0,p2_x],
        [6,p2_x - dir_vec/3.0],
        [7.5,p2_x - dir_vec/2.0]

      # Shine when accalerating
      curve = Animation::Linear_Animation.new -> (o,v) {o.tone = Tone.new v,v,v},
        [6,0],
        [7.5,255]
      @sprites[:poke].add_curve curve
      @sprites[:poke2].add_curve curve

      wait_all.call

      # Reveal fusion
      @sprites[:poke].visible = @sprites[:poke2].visible = false  
      @sprites[:fpoke].x, @sprites[:fpoke].y = 125, 75
      @sprites[:fpoke].create_curve -> (o,v) {o.tone = Tone.new v,v,v},
        [0,255],
        [0.2,0],
        [3,0]
      
      wait_all.call

      # Reset
      load_forground_pokemon
    end
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
