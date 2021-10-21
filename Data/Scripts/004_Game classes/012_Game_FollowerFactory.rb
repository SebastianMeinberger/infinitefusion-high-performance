class FollowerData
  attr_accessor :original_map_id
  attr_accessor :event_id
  attr_accessor :event_name
  attr_accessor :current_map_id
  attr_accessor :x, :y
  attr_accessor :direction
  attr_accessor :character_name, :character_hue
  attr_accessor :name
  attr_accessor :common_event_id
  attr_accessor :visible

  def initialize(original_map_id, event_id, event_name, current_map_id, x, y,
                 direction, character_name, character_hue)
    @original_map_id = original_map_id
    @event_id        = event_id
    @event_name      = event_name
    @current_map_id  = current_map_id
    @x               = x
    @y               = y
    @direction       = direction
    @character_name  = character_name
    @character_hue   = character_hue
    @visible         = true
  end
end

#===============================================================================
#
#===============================================================================
class Game_FollowerFactory
  attr_reader :last_update

  def initialize
    @events      = []
    $PokemonGlobal.followers.each do |follower|
      @events.push(create_follower_object(follower))
    end
    @last_update = -1
  end

  #=============================================================================

  def add_follower(event, name = nil, common_event_id = nil)
    return if !event
    followers = $PokemonGlobal.followers
    if followers.any? { |data| data.original_map_id == $game_map.map_id && data.event_id == event.id }
      return   # Event is already dependent
    end
    eventData = FollowerData.new($game_map.map_id, event.id, event.name,
                                 $game_map.map_id, event.x, event.y, event.direction,
                                 event.character_name.clone, event.character_hue)
    eventData.name            = name
    eventData.common_event_id = common_event_id
    newEvent = create_follower_object(eventData)
    followers.push(eventData)
    @events.push(newEvent)
    @last_update += 1
    event.erase
  end

  def remove_follower_by_event(event)
    followers = $PokemonGlobal.followers
    map_id = $game_map.map_id
    followers.each_with_index do |follower, i|
      next if follower.current_map_id != map_id
      next if follower.original_map_id != event.map_id
      next if follower.event_id != event.id
      followers[i] = nil
      @events[i] = nil
      @last_update += 1
    end
    followers.compact!
    @events.compact!
  end

  def remove_follower_by_name(name)
    followers = $PokemonGlobal.followers
    followers.each_with_index do |follower, i|
      next if follower.name != name
      followers[i] = nil
      @events[i] = nil
      @last_update += 1
    end
    followers.compact!
    @events.compact!
  end

  def remove_all_followers
    $PokemonGlobal.followers.clear
    @events.clear
    @last_update += 1
  end

  def get_follower_by_index(index = 0)
    @events.each_with_index { |event, i| return event if i == index }
    return nil
  end

  def get_follower_by_name(name)
    each_follower { |event, follower| return event if follower&.name == name }
    return nil
  end

  def each_follower
    $PokemonGlobal.followers.each_with_index { |follower, i| yield @events[i], follower }
  end

  #=============================================================================

  def turn_followers
    leader = $game_player
    $PokemonGlobal.followers.each_with_index do |follower, i|
      event = @events[i]
      event.turn_towards_leader(leader)
      follower.direction = event.direction
      leader = event
    end
  end

  def move_followers
    leader = $game_player
    $PokemonGlobal.followers.each_with_index do |follower, i|
      event = @events[i]
      event.follow_leader(leader, false, (i == 0))
      follower.x              = event.x
      follower.y              = event.y
      follower.current_map_id = event.map.map_id
      follower.direction      = event.direction
      leader = event
    end
  end

  def map_transfer_followers
    $PokemonGlobal.followers.each_with_index do |follower, i|
      event = @events[i]
      event.map = $game_map
      event.moveto($game_player.x, $game_player.y)
      event.direction = $game_player.direction
      follower.x              = event.x
      follower.y              = event.y
      follower.current_map_id = event.map.map_id
      follower.direction      = event.direction
    end
  end

  #=============================================================================

  def update
    followers = $PokemonGlobal.followers
    return if followers.length == 0
    # Update all followers
    leader = $game_player
    followers.each_with_index do |follower, i|
      event = @events[i]
      next if !@events[i]
      event.transparent = $game_player.transparent
      event.move_speed  = leader.move_speed
      event.transparent = !follower.visible
      if $PokemonGlobal.sliding
        event.straighten
        event.walk_anime = false
      else
        event.walk_anime = true
      end
      if event.jumping? || event.moving? ||
         !($game_player.jumping? || $game_player.moving?)
        event.update
      elsif !event.starting
        event.set_starting
        event.update
        event.clear_starting
      end
      follower.direction = event.direction
      leader = event
    end
    # Check event triggers
    if Input.trigger?(Input::USE) && !$game_temp.in_menu && !$game_temp.in_battle &&
       !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
       !pbMapInterpreterRunning?
      # Get position of tile facing the player
      facing_tile = $map_factory.getFacingTile
      # Assumes player is 1x1 tile in size
      each_follower do |event, follower|
        next if !follower.common_event_id
        next if event.jumping?
        if event.at_coordinate?($game_player.x, $game_player.y)
          # On same position
          if event.over_trigger? && event.list.size > 1
            # Start event
            $game_map.refresh if $game_map.need_refresh
            event.lock
            pbMapInterpreter.setup(event.list, event.id, event.map.map_id)
          end
        elsif facing_tile && event.map.map_id == facing_tile[0] &&
              event.at_coordinate?(facing_tile[1], facing_tile[2])
          # On facing tile
          if !event.over_trigger? && event.list.size > 1
            # Start event
            $game_map.refresh if $game_map.need_refresh
            event.lock
            pbMapInterpreter.setup(event.list, event.id, event.map.map_id)
          end
        end
      end
    end
  end

  #=============================================================================

  private

  def create_follower_object(event_data)
    return Game_Follower.new(event_data)
  end
end

#===============================================================================
#
#===============================================================================
class FollowerSprites
  def initialize(viewport)
    @viewport    = viewport
    @sprites     = []
    @last_update = nil
    @disposed    = false
  end

  def dispose
    return if @disposed
    @sprites.each { |sprite| sprite.dispose }
    @sprites.clear
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def refresh
    @sprites.each { |sprite| sprite.dispose }
    @sprites.clear
    $game_temp.followers.each_follower do |event, follower|
      $map_factory.maps.each do |map|
        map.events[follower.event_id].erase if follower.original_map_id == map.map_id
      end
      @sprites.push(Sprite_Character.new(@viewport, event))
    end
  end

  def update
    if $game_temp.followers.last_update != @last_update
      refresh
      @last_update = $game_temp.followers.last_update
    end
    @sprites.each { |sprite| sprite.update }
  end
end

#===============================================================================
# Stores Game_Follower instances just for the current play session.
#===============================================================================
class Game_Temp
  attr_writer :followers

  def followers
    @followers = Game_FollowerFactory.new if !@followers
    return @followers
  end
end

#===============================================================================
# Permanently stores data of dependent events (i.e. in save files).
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :dependentEvents   # Deprecated
  attr_writer   :followers

  def followers
    @followers = [] if !@followers
    return @followers
  end
end

#===============================================================================
# Helper module for adding/removing/getting followers.
#===============================================================================
module Followers
  module_function

  # @param event_id [Integer] ID of the event on the current map to be added as a follower
  # @param name [String] identifier name of the follower to be added
  # @param common_event_id [Integer] ID of the Common Event triggered when interacting with this follower
  def add(event_id, name, common_event_id)
    $game_temp.followers.add_follower($game_map.events[event_id], name, common_event_id)
  end

  # @param event [Game_Event] map event to be added as a follower
  def add_event(event)
    $game_temp.followers.add_follower(event)
  end

  # @param name [String] identifier name of the follower to be removed
  def remove(name)
    $game_temp.followers.remove_follower_by_name(name)
  end

  # @param event [Game_Event] map event to be removed as a follower
  def remove_event(event)
    $game_temp.followers.remove_follower_by_event(event)
  end

  # Removes all followers.
  def clear
    $game_temp.followers.remove_all_followers
    pbDeregisterPartner rescue nil
  end

  # @param name [String, nil] name of the follower to get, or nil for the first follower
  # @return [Game_Follower, nil] follower object
  def get(name = nil)
    return $game_temp.followers.get_follower_by_name(name) if name
    $game_temp.followers.get_follower_by_index
    return nil
  end
end


#===============================================================================
# Deprecated methods
#===============================================================================
def pbAddDependency2(event_id, name, common_event_id)
  Deprecation.warn_method('pbAddDependency2', 'v21', 'Followers.add(event_id, name, common_event_id)')
  Followers.add_event(event)
end

def pbAddDependency(event)
  Deprecation.warn_method('pbAddDependency', 'v21', 'Followers.add_event(event)')
  Followers.add_event(event)
end

def pbRemoveDependency2(name)
  Deprecation.warn_method('pbRemoveDependency2', 'v21', 'Followers.remove(name)')
  Followers.remove(name)
end

def pbRemoveDependency(event)
  Deprecation.warn_method('pbRemoveDependency', 'v21', 'Followers.remove_event(event)')
  Followers.remove_event(event)
end

def pbRemoveDependencies
  Deprecation.warn_method('pbRemoveDependencies', 'v21', 'Followers.clear')
  Followers.clear
end

def pbGetDependency(name)
  Deprecation.warn_method('pbGetDependency', 'v21', 'Followers.get(name)')
  Followers.get(name)
end
