def pbAddPokemonID(pokemon, level = nil, seeform = true, dontRandomize = false)
  return if !pokemon || !$Trainer
  dontRandomize = true if $game_switches[3] #when choosing starters

  if pbBoxesFull?
    Kernel.pbMessage(_INTL("There's no more room for Pokémon!\1"))
    Kernel.pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end

  if pokemon.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon, level, $Trainer)
  end
  #random species if randomized gift pokemon &  wild poke
  if $game_switches[780] && $game_switches[778] && !dontRandomize
    oldSpecies = pokemon.species
    pokemon.species = $PokemonGlobal.psuedoBSTHash[oldSpecies]
  end

  speciesname = PBSpecies.getName(pokemon.species)
  Kernel.pbMessage(_INTL("{1} obtained {2}!\\se[itemlevel]\1", $Trainer.name, speciesname))
  pbNicknameAndStore(pokemon)
  pbSeenForm(pokemon) if seeform
  return true
end


def pbAddPokemonID(pokemon_id, level = 1, see_form = true, skip_randomize = false)
  return false if !pokemon_id
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  if pokemon_id.is_a?(Integer) && level.is_a?(Integer)
    pokemon = Pokemon.new(pokemon_id, level)
    species_name = pokemon.speciesName
  end


  #random species if randomized gift pokemon &  wild poke
  if $game_switches[780] && $game_switches[778] && !skip_randomize
    oldSpecies = pokemon.species
    pokemon.species = $PokemonGlobal.psuedoBSTHash[oldSpecies]
  end

  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pokemon)
  $Trainer.pokedex.register(pokemon) if see_form
  return true
end


def pbGenerateEgg(pokemon, text = "")
  return false if !pokemon || !$Trainer # || $Trainer.party.length>=6
  if pokemon.is_a?(String) || pokemon.is_a?(Symbol)
    pokemon = getID(PBSpecies, pokemon)
  end
  if pokemon.is_a?(Integer)
    pokemon = PokeBattle_Pokemon.new(pokemon, EGGINITIALLEVEL, $Trainer)
  end
  # Get egg steps
  eggsteps = $pkmn_dex[pokemon.species][10]
  # Set egg's details
  pokemon.name = _INTL("Egg")
  pokemon.eggsteps = eggsteps
  pokemon.obtainText = text
  pokemon.calcStats
  # Add egg to party
  Kernel.pbMessage(_INTL("Received a Pokémon egg!"))
  if $Trainer.party.length < 6
    $Trainer.party[$Trainer.party.length] = pokemon
  else
    $PokemonStorage.pbStoreCaught(pokemon)
    Kernel.pbMessage(_INTL("The egg was transfered to the PC."))

  end
  #$Trainer.party[$Trainer.party.length]=pokemon
  return true
end




def pbHasSpecies?(species)
  if species.is_a?(String) || species.is_a?(Symbol)
    species = getID(PBSpecies, species)
  end
  for pokemon in $Trainer.party
    next if pokemon.isEgg?
    return true if pokemon.species == species
  end
  return false
end


#Check if the Pokemon can learn a TM
def CanLearnMove(pokemon, move)
  species = getID(PBSpecies, pokemon)
  ret = false
  return false if species <= 0
  data = load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? { |item| item == species }
end

def getBodyID(species)
  return (species / NB_POKEMON).round
end

def getHeadID(species, bodyId)
  return (species - (bodyId * NB_POKEMON)).round
end

def getAllNonLegendaryPokemon()
  list= []
  for i in 1..143
    list.push(i)
  end
  for i in 147..149
    list.push(i)
  end
  for i in 152..242
    list.push(i)
  end
  list.push(246)
  list.push(247)
  list.push(248)
  for i in 252..314
    list.push(i)
  end
  for i in 316..339
    list.push(i)
  end
  for i in 352..377
    list.push(i)
  end
  for i in 382..420
    list.push(i)
  end
  return list
end

def getPokemonEggGroups(species)
  groups = []

  compat10=$pkmn_dex[species][13][0]
  compat11=$pkmn_dex[species][13][1]

  groups << compat10
  groups << compat11
  return groups
end

def generateEggGroupTeam(eggGroup)
  teamComplete = false
  generatedTeam = []
  while !teamComplete
    species = rand(PBSpecies.maxValue)
    if getPokemonEggGroups(species).include?(eggGroup)
      generatedTeam << species
    end
    teamComplete = generatedTeam.length == 3
  end
  return generatedTeam
end

def pbGetSelfSwitch(eventId,switch)
  return $game_self_switches[[@map_id,eventId,switch]]
end

def obtainBadgeMessage(badgeName)
  Kernel.pbMessage(_INTL("\\me[Badge get]{1} obtained the {2}!",$Trainer.name,badgeName))
end


def generateSameEggGroupFusionsTeam(eggGroup)
  teamComplete = false
  generatedTeam = []
  while !teamComplete
    foundFusionPartner = false
    species1 = rand(NB_POKEMON)
    if getPokemonEggGroups(species1).include?(eggGroup)
      foundFusionPartner = false
      while !foundFusionPartner
        species2 = rand(NB_POKEMON)
        if getPokemonEggGroups(species2).include?(eggGroup)
          generatedTeam << getFusionSpecies(species1,species2)
          foundFusionPartner = true
        end
      end
    end
    teamComplete = generatedTeam.length == 3
  end
  return generatedTeam
end

def getAllNonLegendaryPokemon()
  list= []
  for i in 1..143
    list.push(i)
  end
  for i in 147..149
    list.push(i)
  end
  for i in 152..242
    list.push(i)
  end
  list.push(246)
  list.push(247)
  list.push(248)
  for i in 252..314
    list.push(i)
  end
  for i in 316..339
    list.push(i)
  end
  for i in 352..377
    list.push(i)
  end
  for i in 382..420
    list.push(i)
  end
  return list
end

def generateSimpleTrainerParty(teamSpecies,level)
  team = []
  for species in teamSpecies
    poke = Pokemon.new(species, level)
    team << poke
  end
  return team
end


def isSinnohPokemon(species)
  list =
    [254,255,256,257,258,259,260,261,262,263,264,265,
     266,267,268,269,270,271,272,273,274,275,288,294,
     295,296,297,298,299,305,306,307,308,315,316,317,
     318,319,320,321,322,323,324,326,332,343,344,345,
     346,347,352,353,354,358,383,384,388,389,400,402,403]
  return list.include?(species)
end


def isHoennPokemon(species)
  list=[252,253,276,277,278,279,280,281,282,283,284,
        285,286,287,289,290,291,292,293,300,301,302,303,
        304,309,310,311,312,313,314,333,334,335,336,340,
        341,342,355,356,357,378,379,380,381,382,385,386,387,390,
        391,392,393,394,395,396,401,404,405]
  return list.include?(species)
end