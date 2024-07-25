#require 'debug'

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
    end

    def initialise_map id, clear_events
      $MapFactory = PokemonMapFactory.new id
      $game_player.moveto(19, 5)
      $PokemonEncounters = PokemonEncounters.new
      $PokemonEncounters.setup($game_map.map_id)
      Events.onMapSceneChange += @@signal_loading_finised
      if clear_events
        $game_map.events.clear
      end
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

    def self.generate_test uuid
      Test_Suite::Test_Scene.subclasses.each do |test_class|
        if test_class.uuid == uuid
          return test_class.new
        end
      end
      puts "Test with uuid #{uuid} not found!"
      return nil
    end
  end
end
