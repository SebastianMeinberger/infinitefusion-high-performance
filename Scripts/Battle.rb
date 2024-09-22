module Battle
  class Battle 
    # Currently, only wraps the old battle class.
    # It would be better to unpack the old one completly.
    def initialize battle_info
      @battle_info = battle_info
      @location = determine_location
      @encounter_type = determine_encounter_type
    end

    def start 
        #start_battle_music @bgm
        
        #binding.b
        # Start animation: sceenflash + transition (Splash stuff on water, these black squares appearing in a snake pattern etc.)
        start_animation = Animation::Sequential.new(
          Animations::Screen_Flash.new(@battle_info.time, @location),
          Animations::Transitions.construct(@battle_info.time, @location, @encounter_type)
        )
        start_animation.play_and_finish
        start_animation.dispose

        message_window = Animations::Start_Text.setup_message_window
        
        # Battle Scene Setup animation: BG appears and slides to the left, player and foe slide in on their backdrops, HP bars, and in case of trainer battle also team indicators, appear and battle start message is played.
        scene_setup_animation = Animation::Sequential.new(
          Animations::BG_Slide.new(@battle_info.backdrop),
          Animations::Start_Text.new(message_window, @battle_info.sideSizes, @encounter_type, @battle_info.party1, @battle_info.party2)
        )
        scene_setup_animation.play_and_finish
    end

    private

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
        return :water
      elsif $PokemonEncounters.has_cave_encounters?
        return :cave
      elsif !GameData::MapMetadata.exists?($game_map.map_id) || !GameData::MapMetadata.get($game_map.map_id).outdoor_map
        return :inside
      else
        return :outside
      end
    end

    def determine_encounter_type
      wild = @battle_info.opponent == nil
      single = @battle_info.sides == [1,1] 
      return :wild if single && wild
      return :doub_wild if !single && wild
      return :trainer if single && !wild
      return :doub_trainer
    end
  end
end

Battle.autoload :Animations, "Battle/Animations"
Battle.autoload :Battle_Info, "Battle/Battle_Info"
