module Test_Suite
  class Pallet_Town_Benchmark < ITest_Scene
    @@uuid = "Pallet_Town_Benchmark".freeze

    def main
      initialise_generic_game_values       
      
      $MapFactory = PokemonMapFactory.new 42
      clear_all_events $game_map
      $game_player.moveto($data_system.start_x, $data_system.start_y)
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup($game_map.map_id)
      $game_map.autoplay
      $game_map.update

    end

    #privat
    
    def initialise_generic_game_values
      pbMapInterpreter&.setup(nil, 0, 0)
      $scene = Scene_Map.new
      SaveData.load_new_game_values
      $game_player.character_name = "walk"
      $Trainer.hat = "red"
      $Trainer.hair = "3_red"
      $Trainer.clothes = "red"
      $Trainer.character_ID = 0
      $Trainer.has_running_shoes = true
    end

    def initialise_switches switches
      switches.each {|switch| $game_self_switches[switch + ["A"]] = true}
    end
    
    def clear_all_events map
      map.events.clear
    end

  end
end
