module Test_Suite
  class Pallet_Town_Benchmark < ITest_Scene
    @@uuid = "Pallet_Town_Benchmark".freeze

    def main
      initialise_generic_game_values                   
      $MapFactory = PokemonMapFactory.new 42
      clear_all_events $game_map      
      $game_player.moveto(19, 5)
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup($game_map.map_id)
      Events.onMapSceneChange += @@signal_loading_finised
      walk_up_and_down 12
    end

    #privat
    @@signal_loading_finised = -> (s,e){
      path = ARGV[0] + "/Raw_Measurments/loadtime"
      puts path
      File.write(path, "loaded\n", mode: "a")
    }

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

    def walk_up_and_down range
      route = RPG::MoveRoute.new
      route.repeat = true
      route.list = (1..range).map {RPG::MoveCommand.new(PBMoveRoute::Forward)}
      route.list += [RPG::MoveCommand.new(PBMoveRoute::Turn180),RPG::MoveCommand.new(0)]
      $game_player.force_move_route(route)
    end

  end
end
