#===============================================================================
# Pokémon sprite (used out of battle)
#===============================================================================
class PokemonSprite < SpriteWrapper
  def initialize(viewport = nil)
    super(viewport)
    @_iconbitmap = nil
  end

  def dispose
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def clearBitmap
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = nil
    self.bitmap = nil
  end

  def setOffset(offset = PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def filename
    return @bitmap
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::Center if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.bitmap.width / 2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.bitmap.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      self.oy = self.bitmap.height / 2
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.bitmap.height
    end
  end

  def setPokemonBitmap(pokemon, back = false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back) : nil
    if @_iconbitmap
      if  pokemon.hat
        add_hat_to_bitmap(@_iconbitmap.bitmap,pokemon.hat,pokemon.hat_x,pokemon.hat_y)
      else

      end
      self.bitmap = @_iconbitmap.bitmap
    else
      @_iconbitmap.bitmap=nil
    end
    self.color = Color.new(0, 0, 0, 0)
    changeOrigin
  end

  def setPokemonBitmapFromId(id, back = false, shiny = false, bodyShiny = false, headShiny = false,spriteform_body=nil,spriteform_head=nil)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = GameData::Species.sprite_bitmap_from_pokemon_id(id, back, shiny, bodyShiny, headShiny)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    self.color = Color.new(0, 0, 0, 0)
    changeOrigin
  end

  def setPokemonBitmapSpecies(pokemon, species, back = false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = (pokemon) ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back, species) : nil
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end

  def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
    @_iconbitmap.dispose if @_iconbitmap
    @_iconbitmap = GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    changeOrigin
  end

  def getBitmap
    return @_iconbitmap
  end

  def update
    super
    if @_iconbitmap
      @_iconbitmap.update
      self.bitmap = @_iconbitmap.bitmap
    end
  end
end

#===============================================================================
# Pokémon icon (for defined Pokémon)
#===============================================================================
class PokemonIconSprite < Animation::Animated_Sprite
  attr_accessor :selected
  attr_accessor :active
  attr_reader :pokemon

  def initialize(pokemon, viewport = nil)
    super(viewport)
    

    @selected = false
    @active = false
    self.pokemon = pokemon
    @offset_x = 0
    @offset_y = 0
    @base_x = 0
    @base_y = 0

    # Jump up and down animation
    end_time = 0.25
    if @pokemon.hp <= @pokemon.totalhp / 4;
      end_time = 1 # Red HP - 1 second
    elsif @pokemon.hp <= @pokemon.totalhp / 2;
      end_time =  0.5 # Yellow HP - 0.5 seconds
    end
    end_time *= 0.5
    self.create_curve :offset_y=, :linear_interpolation, [0, 0], [end_time,3], looping: true
  end

  def offset_x= value
    @offset_x = value
    update_position
  end

  def offset_y= value
    @offset_y = value
    update_position
  end

  def base_x= value
    @base_x = value
    update_position
  end

  def base_y= value
    @base_y = value
    update_position
  end

  def update_position
    self.x = @base_x + @offset_x
    self.y = @base_y + @offset_y
  end

  def dispose
    @animBitmap.dispose if @animBitmap
    super
  end
 
  def animBitmap=(value)
    @animBitmap = value
  end

  def pokemon=(value)
    @pokemon = value
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    if !@pokemon
      self.bitmap = nil
      @currentFrame = 0
      @counter = 0
      return
    end
    if useRegularIcon(@pokemon.species) || @pokemon.egg?
      @animBitmap = AnimatedBitmap.new(GameData::Species.icon_filename_from_pokemon(value))
    elsif useTripleFusionIcon(@pokemon.species)
      @animBitmap = AnimatedBitmap.new(pbResolveBitmap(sprintf("Graphics/Icons/iconDNA")))
    else
      @animBitmap = createFusionIcon()
    end
    self.bitmap = @animBitmap.bitmap
    # Icon bitmaps are all double in sice for deprecated animation reasons => only left halfe is needed
    self.src_rect.width = self.bitmap.width/2
  end

  def useTripleFusionIcon(species)
    dexNum = getDexNumberForSpecies(species)
    return isTripleFusion?(dexNum)
  end

  def useRegularIcon(species)
    dexNum = getDexNumberForSpecies(species)
    return true if dexNum <= Settings::NB_POKEMON
    return false if $game_variables == nil
    return true if $game_variables[VAR_FUSION_ICON_STYLE] != 0
    bitmapFileName = sprintf("Graphics/Icons/icon%03d", dexNum)
    return true if pbResolveBitmap(bitmapFileName)
    return false
  end

  SPRITE_OFFSET = 10

  def createFusionIcon()
    bodyPoke_number = getBodyID(pokemon.species)
    headPoke_number = getHeadID(pokemon.species, bodyPoke_number)

    bodyPoke = GameData::Species.get(bodyPoke_number).species
    headPoke = GameData::Species.get(headPoke_number).species

    icon1 = AnimatedBitmap.new(GameData::Species.icon_filename(headPoke, @pokemon.spriteform_head))
    icon2 = AnimatedBitmap.new(GameData::Species.icon_filename(bodyPoke, @pokemon.spriteform_body))

    dexNum = getDexNumberForSpecies(@pokemon.species)
    ensureFusionIconExists
    bitmapFileName = sprintf("Graphics/Pokemon/FusionIcons/icon%03d", dexNum)
    headPokeFileName = GameData::Species.icon_filename(headPoke, @pokemon.spriteform_head)

    bitmapPath = sprintf("%s.png", bitmapFileName)
    generated_new_icon = generateFusionIcon(headPokeFileName, bitmapPath)
    result_icon = generated_new_icon ? AnimatedBitmap.new(bitmapPath) : icon1

    for i in 0..icon1.width - 1
      for j in ((icon1.height / 2) + Settings::FUSION_ICON_SPRITE_OFFSET)..icon1.height - 1
        temp = icon2.bitmap.get_pixel(i, j)
        result_icon.bitmap.set_pixel(i, j, temp)
      end
    end
    return result_icon
  end 
end

#===============================================================================
# Pokémon icon (for species)
#===============================================================================
class PokemonSpeciesIconSprite < SpriteWrapper
  attr_reader :species
  attr_reader :gender
  attr_reader :form
  attr_reader :shiny

  def initialize(species, viewport = nil)
    super(viewport)
    @species = species
    @gender = 0
    @form = 0
    @shiny = 0
    @numFrames = 0
    @currentFrame = 0
    @counter = 0
    refresh
  end

  def dispose
    @animBitmap.dispose if @animBitmap
    super
  end

  def species=(value)
    @species = value
    refresh
  end

  def gender=(value)
    @gender = value
    refresh
  end

  def form=(value)
    @form = value
    refresh
  end

  def shiny=(value)
    print "wut"
    @shiny = value
    refresh
  end

  def pbSetParams(species, gender, form, shiny = false)
    @species = species
    @gender = gender
    @form = form
    @shiny = shiny
    refresh
  end

  def setOffset(offset = PictureOrigin::Center)
    @offset = offset
    changeOrigin
  end

  def changeOrigin
    return if !self.bitmap
    @offset = PictureOrigin::TopLeft if !@offset
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
      self.ox = 0
    when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
      self.ox = self.src_rect.width / 2
    when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
      self.ox = self.src_rect.width
    end
    case @offset
    when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
      self.oy = 0
    when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
      # NOTE: This assumes the top quarter of the icon is blank, so oy is placed
      #       in the middle of the lower three quarters of the image.
      self.oy = self.src_rect.height * 5 / 8
    when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
      self.oy = self.src_rect.height
    end
  end

  # How long to show each frame of the icon for
  def counterLimit
    # ret is initially the time a whole animation cycle lasts. It is divided by
    # the number of frames in that cycle at the end.
    ret = Graphics.frame_rate / 4 # 0.25 seconds
    ret /= @numFrames
    ret = 1 if ret < 1
    return ret
  end

  def refresh
    @animBitmap.dispose if @animBitmap
    @animBitmap = nil
    bitmapFileName = GameData::Species.icon_filename(@species, @form, @gender, @shiny)
    return if !bitmapFileName
    @animBitmap = AnimatedBitmap.new(bitmapFileName)
    self.bitmap = @animBitmap.bitmap
    self.src_rect.width = @animBitmap.height
    self.src_rect.height = @animBitmap.height
    @numFrames = @animBitmap.width / @animBitmap.height
    @currentFrame = 0 if @currentFrame >= @numFrames
    changeOrigin
  end

  def update
    return if !@animBitmap
    super
    @animBitmap.update
    self.bitmap = @animBitmap.bitmap
    # Update animation
    @counter += 1
    if @counter >= self.counterLimit
      @currentFrame = (@currentFrame + 1) % @numFrames
      @counter = 0
    end
    self.src_rect.x = self.src_rect.width * @currentFrame
  end
end
