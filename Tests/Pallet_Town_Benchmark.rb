module Test_Suite
  class Pallet_Town_Benchmark < Test_Scene
    @@uuid = "Pallet_Town_Benchmark".freeze
    def main
      initialise_game_values
      # Load Pallet Town without any events
      initialise_map 42, true
      $game_player.moveto(19, 5)

      # Let the player walk up and down in the middle, where the lagspike border is
      route = [12,:f]
      force_player_route_com route, true
    end
  end

  class Saffron_City_Benchmark < Test_Scene
    @@uuid = "Saffron_City_Benchmark".freeze
    def main
      initialise_game_values
      # Load Saffron City without any events
      initialise_map 108, true
      
      # Let the player walk around in a big circle on the outer street of Saffron
      $game_player.moveto(16, 18)
      #route = [PBMoveRoute::Forward] * 31 + [PBMoveRoute::TurnLeft90] + [PBMoveRoute::Forward] * 53 + [PBMoveRoute::TurnLeft90]
      route = [31,:l,53,:l]
      force_player_route_com route, true
    end
  end

  class Safari_5_Benchmark < Test_Scene
    @@uuid = "Safari_5_Benchmark".freeze
    def main
      initialise_game_values
      initialise_map 487, true
      
      # Some random route around area 5 
      $game_player.moveto(14, 21)
        route = [9,:l,18,:l,6,:r,5,:r,5,:l,7,:r,2,:r,6,:r,2,:l,1,:r,5,:l,10,:r,3,:l,13,:l]
      force_player_route_com route, true
    end
  end

end
