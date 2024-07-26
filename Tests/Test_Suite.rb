require 'debug'
module Test_Suite

  class Test_Scene

    @@uuid = "0".freeze
    def self.uuid
      return @@uuid
    end

    def initialise_game_values
      pbMapInterpreter&.setup(nil, 0, 0)
      $scene = Scene_Map.new
      SaveData.load_new_game_values
      $game_player.character_name = "walk"
      $Trainer.hat = "red"
      $Trainer.hair = "3_red"
      $Trainer.clothes = "red"
      $Trainer.character_ID = 0
      $Trainer.has_running_shoes = true
      Events.onMapSceneChange += @@signal_loading_finised
    end

    def initialise_map id, clear_events
      $MapFactory = PokemonMapFactory.new id
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup $game_map.map_id
      if clear_events
        $game_map.events.clear
      end
    end

    def force_player_route list_move_command_codes, repeat
      route = RPG::MoveRoute.new
      route.list = list_move_command_codes.map {|c| RPG::MoveCommand.new c}
      route.repeat = repeat
      if repeat
        # For some reason that is neccessary for looping the route
        route.list.append RPG::MoveCommand.new 0
      end 
      $game_player.force_move_route route
    end

    def force_player_route list_move_command_codes, repeat
      route = RPG::MoveRoute.new
      route.list = []
      list_move_command_codes.each do |c|
        if c.is_a? Integer
          route.list += [RPG::MoveCommand.new(PBMoveRoute::Forward)] * c
        elsif c == :l
          route.list += [RPG::MoveCommand.new(PBMoveRoute::TurnLeft90)]
        elsif c == :r
          route.list += [RPG::MoveCommand.new(PBMoveRoute::TurnRight90)]
        elsif c == :f
          route.list += [RPG::MoveCommand.new(PBMoveRoute::Turn180)]
        end
      end
      route.repeat = repeat
      if repeat
        # For some reason that is neccessary for looping the route
        route.list.append RPG::MoveCommand.new 0
      end 
      $game_player.force_move_route route
    end


    @@signal_loading_finised = -> (s,e){
      if ARGV.length > 0
        path = ARGV[-1] + "/Raw_Measurments/loadtime"
        puts path
        File.write(path, "loaded\n", mode: "a")
      end
    }

  end

  class Test_Scene_Factory
    def self.generate_all_tests
      test_scenes = []
      Test_Suite::Test_Scene.subclasses.each do |test_class|
        test_scenes.push test_class.new
      end

      return test_scenes
    end

    def self.generate_test name
      Test_Suite::Test_Scene.subclasses.each do |test_class|
        if test_class.name == "Test_Suite::" + name
          return test_class.new
        end
      end
      puts "Test with name #{name} not found!"
      return nil
    end
  end
end
