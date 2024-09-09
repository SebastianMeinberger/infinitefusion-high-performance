module Battle
end

module Battle::Constants
  # Create enums for all factors influencing the choice of the transition
  DAY, EVENING, NIGHT = (0..2).to_a
  OUTSIDE, INSIDE, CAVE, WATER = (0..3).to_a
  WILD, TRAINER, DOUB_WILD, DOUB_TRAINER = (0..3).to_a
end


module Battle
  class Battle
    
    def initialize encounter, encounter_type
      @encounter = encounter
      @encounter_type = encounter_type
    end

    include Constants
    def start
        #start_battle_music @bgm
        # Determine the relevant enviorment infos
        time = determine_time
        location = determine_location

        viewport = Viewport.new 0, 0, Graphics.width, Graphics.height
        viewport.z = 9999

        # Start animation: sceenflash + transition (Splash stuff on water, these black squares appearing in a snake pattern etc.)
        start_animation = Animation::Container.new
        start_animation.schedule_next(
          Animations::Screen_Flash.new(time, location),
          Animations::Transitions::Transition.animate(time, location, @encounter_type)
        )
        start_animation.play_and_finish
        start_animation.dispose

        # Battle Scene Setup animation: BG appears and slides to the left, player and foe slide in on these weird ground circels, HP bars, and in case of trainer battle also team indicators, appear and battle start message is played.
        
        messageBG = Animation::Implementations::Animated_Sprite.new viewport
        messageBG.y = Graphics.height - 96
        messageBG.bitmap = Bitmap.new "Graphics/Pictures/Battle/overlay_message"
        message_window = Window_AdvancedTextPokemon.new x: 16, y: Graphics.height - 96 + 2, width: Graphics.width - 32, height: 96, viewport: viewport

        bs_setup_animation = Animation::Container.new
        bs_setup_animation.schedule_next(
          Animations::BG_Slide.new(time)
        )

        bs_setup_animation.play_and_finish
    end
   
    def start_battle_music bgm
      @previous_bgm = $game_system.getPlayingBGS
      @previous_bgs = $game_system.getPlayingBGM
      $game_system.bgm_pause
      $game_system.bgs_pause 
      pbMEStop 0.25
      pbBGMPlay bgm
    end

    def determine_location
      if $PokemonGlobal.surfing || $PokemonGlobal.diving || ($PokemonTemp.encounterType && GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing)
        return WATER
      elsif $PokemonEncounters.has_cave_encounters?
        return CAVE
      elsif !GameData::MapMetadata.exists?($game_map.map_id) || !GameData::MapMetadata.get($game_map.map_id).outdoor_map
        return INSIDE
      else
        return OUTSIDE
      end
    end

    def determine_time
      if PBDayNight.isEvening?
        return EVENING
      elsif PBDayNight.isNight?
        return NIGHT
      else
        return DAY
      end
    end
  end
end

module Battle::Animations
end
