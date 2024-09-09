module Battle::Animations
  class BG_Slide < Animation::Container
    def initialize time
      super()
      @bg = Animation::Implementations::Animated_Sprite.new
      base_bitmap = pbBitmap generate_bitmap_path(time)
      # In order to have an image that is wide enough to slide it across the screen, but still have it fill it entierly, the bitmap is extended by its mirrored self on the left.
      w, h = base_bitmap.width, base_bitmap.height
      extended_bitmap = Bitmap.new w*1.5, h
      extended_bitmap.stretch_blt Rect.new(0, 0, w*0.5, h), base_bitmap, Rect.new(w*0.5, 0, -w*0.5, h)
      extended_bitmap.stretch_blt Rect.new(w*0.5, 0, w, h), base_bitmap, Rect.new(0, 0, w, h)

      @bg.bitmap = extended_bitmap
      @bg.z = 99999
      schedule_next @bg.animate_property :x, [1,-Graphics.width/2]
    end

    def generate_bitmap_path time
      bitmap_path = "Graphics/Battlebacks/battlebg/"
      metadata = GameData::MapMetadata.get($game_map.map_id)
      # look if map specifies a batttle background
      if metadata.battle_background
        # For some reason, some maps have wrong capitalisation an there saved bgs 
        bitmap_path += metadata.battle_background.downcase
      # check if map is a city
      elsif metadata.teleport_destination && metadata.announce_location && metadata.outdoor_map
        bitmap_path += "city"
      # Just use the background corresponding to the environment
      else
        battle_env = metadata.battle_environment
        case battle_env
        when :Cave
          bitmap_path += "cave1"
        when :Grass
          bitmap_path += "field"
        when :Rock
          bitmap_path += "mountain"
        when :Underwater
          bitmap_path += "underwater"
        when :StillWater
          bitmap_path += "water"
        when :MovingWater
          bitmap_path += "water"
        when :Forest
          bitmap_path += "forest"
        end
      end
      # TODO time suffix stuff
      return bitmap_path
    end

  end
end
