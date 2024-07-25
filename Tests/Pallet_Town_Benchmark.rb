module Test_Suite
  class Pallet_Town_Benchmark < Test_Scene
    @@uuid = "Pallet_Town_Benchmark".freeze

    def main
      initialise_game_values
      initialise_map 42, true
      walk_up_and_down 12
    end
     
    def initialise_switches switches
      switches.each {|switch| $game_self_switches[switch + ["A"]] = true}
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
