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
    intro_sprite.bitmap.looping = false
    intro_sprite.bitmap.play
    pbBGMPlay("INTRO_music_cries")
    while intro_sprite.bitmap.playing do
      Graphics.update
      Input.update
      if Input.press?(Input::C)
        break
      end
    end
    pbBGMStop
  end

  def main
    Graphics.transition(0)
    # Cycles through the intro pictures
    @skip = false

    playIntroCinematic
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
      @screen.update
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

  def wait(frames)
    return if @skip
    frames.times do
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
  end
end

#===============================================================================
# Styled to look like the FRLG games
#===============================================================================
class GenOneStyle

  def initialize
    Kernel.pbDisplayText("Keybindings: F1", 80, 0, 99999)
    Kernel.pbDisplayText("Version " + Settings::GAME_VERSION_NUMBER, 254, 308, 99999)

    @maxPoke = 140 #1st gen, pas de legend la premiere fois, graduellement plus de poke
    @customPokeList = getCustomSpeciesList(false)
    #Get random Pokemon (1st gen orandPokenly, pas de legend la prmeiere fois)

    randPoke = getRandomCustomFusionForIntro(true, @customPokeList, @maxPoke)
    randpoke1 = randPoke[0] #rand(@maxPoke)+1
    randpoke2 = randPoke[1] #rand(@maxPoke)+1

    randpoke2s = randpoke2.to_s

    path_s1 = get_unfused_sprite_path(randpoke1)
    path_s2 = get_unfused_sprite_path(randpoke2)
    path_f = get_fusion_sprite_path(randpoke1, randpoke2)

    @prevPoke1 = randpoke1
    @prevPoke2 = randpoke2

    #Get Fused Poke
    fusedpoke = (randpoke2 * NB_POKEMON) + randpoke1
    fusedpoke_s = fusedpoke.to_s

    @selector_pos = 0 #1: left, 0:right

    # sound file for playing the title screen BGM
    bgm = "Pokemon Red-Blue Opening"
    @skip = false
    # speed of the effect movement
    @speed = 16
    @opacity = 17
    @disposed = false

    @currentFrame = 0
    # calculates after how many frames the game will reset
    @totalFrames = 10 * Graphics.frame_rate

    pbBGMPlay(bgm)

    # creates all the necessary graphics
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    @sprites = {}

    @sprites["bars"] = Sprite.new(@viewport)
    @sprites["bars"].bitmap = pbBitmap("Graphics/Titles/gen1_bars")
    @sprites["bars"].x = Graphics.width
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/Titles/gen1_bg")
    @sprites["bg"].x = -Graphics.width

    @sprites["effect"] = AnimatedPlane.new(@viewport)
    @sprites["effect"].bitmap = pbBitmap("Graphics/Titles/gen1_effect")
    @sprites["effect"].opacity = 155
    @sprites["effect"].visible = false

    @sprites["selector"] = Sprite.new(@viewport)
    @sprites["selector"].bitmap = pbBitmap("Graphics/Titles/selector")
    @sprites["selector"].x = 0
    @sprites["selector"].y = 200
    @sprites["selector"].opacity = 0

    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = pbBitmap(path_s1)
    @sprites["poke"].x = 400
    @sprites["poke"].y = 75

    @sprites["2poke"] = Sprite.new(@viewport)
    @sprites["2poke"].bitmap = pbBitmap(path_s2)
    @sprites["2poke"].x = -150
    @sprites["2poke"].y = 75

    @sprites["fpoke"] = Sprite.new(@viewport)
    @sprites["fpoke"].bitmap = pbBitmap(path_f)
    @sprites["fpoke"].x = 125
    @sprites["fpoke"].y = 75
    @sprites["fpoke"].z = 999
    @sprites["fpoke"].opacity = 0

    @sprites["poke"].tone = Tone.new(0, 0, 0, 255)
    @sprites["poke"].opacity = 0
    @sprites["poke2"] = Sprite.new(@viewport)
    # @sprites["poke2"].bitmap = pbBitmap("Graphics/Battlers/21364")
    @sprites["poke2"].tone = Tone.new(255, 255, 255, 255)
    @sprites["poke2"].src_rect.set(0, Graphics.height, Graphics.width, 48)
    @sprites["poke2"].y = Graphics.height
    @sprites["poke2"].y = 100

    @sprites["2poke"].tone = Tone.new(0, 0, 0, 255)
    @sprites["2poke"].opacity = 0
    @sprites["2poke2"] = Sprite.new(@viewport)
    @sprites["2poke2"].bitmap = pbBitmap("Graphics/Battlers/special/000")
    @sprites["2poke2"].tone = Tone.new(255, 255, 255, 255)
    @sprites["2poke2"].src_rect.set(0, Graphics.height, Graphics.width, 48)
    @sprites["2poke2"].y = Graphics.height
    @sprites["2poke2"].y = 100

    @sprites["logo"] = Sprite.new(@viewport)
    bitmap1 = pbBitmap("Graphics/Titles/pokelogo")
    @sprites["logo"].bitmap = Bitmap.new(bitmap1.width, bitmap1.height)
    @sprites["logo"].bitmap.blt(0, 0, bitmap1, Rect.new(0, 0, bitmap1.width, bitmap1.height))
    @sprites["logo"].tone = Tone.new(255, 255, 255, 255)
    @sprites["logo"].x = 50
    @sprites["logo"].y = -20
    @sprites["logo"].opacity = 0

    @sprites["star"] = Sprite.new(@viewport)
    @sprites["star"].bitmap = pbBitmap("Graphics/Pictures/darkness")
    @sprites["star"].opacity = 0
    @sprites["star"].x = -50
    @sprites["star"].y = 0

  end

  def intro
    wait(16)
    16.times do
    end
    wait(32)
    64.times do

      @sprites["2poke"].opacity += 4
      @sprites["poke"].opacity += 4
      wait(1)
    end
    8.times do
      @sprites["bg"].x += 64
      wait(1)
    end
    wait(8)
    8.times do
      @sprites["bars"].x -= 64
      wait(1)
    end
    wait(8)
    @sprites["logo"].opacity = 255
    @sprites["poke2"].opacity = 255
    @sprites["2poke2"].opacity = 255

    @sprites["poke"].tone = Tone.new(0, 0, 0, 0)
    @sprites["2poke"].tone = Tone.new(0, 0, 0, 0)

    @sprites["effect"].visible = false
    c = 255.0
    16.times do
      @sprites["poke2"].opacity -= 255.0 / 16
      @sprites["2poke2"].opacity -= 255.0 / 16

      c -= 255.0 / 16
      @sprites["logo"].tone = Tone.new(c, c, c)
      @sprites["effect"].ox += @speed

      wait(1)
    end
  end

  TONE_INCR = 15

  def makeShineEffect()
    newColor = @sprites["poke"].tone.red + TONE_INCR
    newTone = Tone.new(newColor, newColor, newColor, 0)
    @sprites["poke"].tone = newTone
    @sprites["2poke"].tone = newTone
  end

  def introloop
    @sprites["star"].opacity = 0
    @sprites["poke"].opacity = 255
    @sprites["2poke"].opacity = 255
    @sprites["fpoke"].opacity = 0
    @sprites["poke"].x = @sprites["poke"].x - 1
    @sprites["2poke"].x = @sprites["2poke"].x + 1

  end

  def update_selector_position()
    if Input.press?(Input::RIGHT) || Input.press?(Input::LEFT)
      if Input.press?(Input::RIGHT)
        @selector_pos = 0
        @sprites["selector"].opacity = 100
      elsif Input.press?(Input::LEFT)
        @selector_pos = 1
        @sprites["selector"].opacity = 100
      end
    else
      @sprites["selector"].opacity=0
    end

    if @selector_pos == 0
      @sprites["selector"].x = @sprites["poke"].x
    else
      @sprites["selector"].x = @sprites["2poke"].x
    end
  end

  def update
    @sprites["effect"].ox += @speed
    @currentFrame += 1
    @skip = false

    if @sprites["poke"].x < 175 #150
      makeShineEffect()
    end
    update_selector_position()
    if @sprites["poke"].x > @sprites["2poke"].x
      @sprites["poke"].x = @sprites["poke"].x - 1
      @sprites["2poke"].x = @sprites["2poke"].x + 1
    end

    if @sprites["poke"].x <= @sprites["2poke"].x
      @sprites["poke"].opacity = 0
      @sprites["2poke"].opacity = 0
      #16.times do
      @sprites["fpoke"].opacity = 255
      @sprites["selector"].opacity = 0
      #wait(1)
      #end
      @sprites["poke"].x = 400
      @sprites["poke"].tone = Tone.new(0, 0, 0, 0)

      @sprites["2poke"].x = -150
      @sprites["2poke"].tone = Tone.new(0, 0, 0, 0)

      if @maxPoke < NB_POKEMON - 1
        @maxPoke += 5 #-1 pour que ca arrive pile. tant pis pour kyurem
      end
      randPoke = getRandomCustomFusionForIntro(true, @customPokeList, @maxPoke)
      randpoke1 = randPoke[0] #rand(@maxPoke)+1
      randpoke2 = randPoke[1] #rand(@maxPoke)+1

      path_s1 = get_unfused_sprite_path(randpoke1)
      path_s2 = get_unfused_sprite_path(randpoke2)
      path_f = getFusedPath(randpoke1, randpoke2)

      path_fMod = getFusedPath(@prevPoke1, @prevPoke2)
      @sprites["fpoke"].bitmap = pbBitmap(path_fMod)

      @prevPoke1 = randpoke1
      @prevPoke2 = randpoke2

      @sprites["poke"].bitmap = pbBitmap(path_s1)
      @sprites["2poke"].bitmap = pbBitmap(path_s2)

      wait(150)
      @sprites["fpoke"].bitmap = pbBitmap(path_f)
    end

    @sprites["fpoke"].opacity -= 10
    @sprites["effect"].ox += @speed

    if @currentFrame >= @totalFrames
      introloop
    end
  end

  #new version
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

def getFusedPatho(randpoke1s, randpoke2s)
  path = rand(2) == 0 ? "Graphics/Battlers/" + randpoke1s + "/" + randpoke1s + "." + randpoke2s : "Graphics/Battlers/" + randpoke2s + "/" + randpoke2s + "." + randpoke1s
  if Input.press?(Input::RIGHT)
    path = "Graphics/Battlers/" + randpoke2s + "/" + randpoke2s + "." + randpoke1s
  elsif Input.press?(Input::LEFT)
    path = "Graphics/Battlers/" + randpoke1s + "/" + randpoke1s + "." + randpoke2s
  end
  return path
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

def wait(frames)
  return if @skip
  frames.times do
    @currentFrame += 1
    @sprites["effect"].ox += @speed

    Graphics.update
    Input.update
    if Input.trigger?(Input::C)
      @skip = true
      return
    end
  end
end
