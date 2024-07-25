module Test_Suite
  class Pallet_Town_Benchmark < Test_Scene
    @@uuid = "Pallet_Town_Benchmark".freeze

    def main
      initialise_game_values
      # Load Pallet Town without any events
      initialise_map 42, true
      $game_player.moveto(19, 5)

      # Let the player walk up and down in the middle, where the lagspike border is
      route = [PBMoveRoute::Forward] * 12 + [PBMoveRoute::Turn180]
      force_player_route route, true
    end

  end
end
