ItemHandlers::BattleUseOnBattler.add(:POKEDEX, proc { |item, battler, scene|
  #if battler.battle.battlers.length  > -1
  #  scene.pbDisplay(_INTL(" The length is {1}",battler.battle.battlers.length))
  #     scene.pbDisplay(_INTL("The PokéDex cannot be used on multiple enemies at once!"))
  #     return false
  #end

  doublebattle = false
  #DOUBLE BATTLES A FAIRE
  #variable temporaire doublebattle
  if doublebattle
    e = battler.pbOpposing2
  else
    is_trainer = battler.battle.opponent

    e1 = battler.pbOpposing1.pokemon
    enemyname = e1.name
    e1type1 = e1.type1
    e1type2 = e1.type2
  end
  if e1type1 == e1type2
    scene.pbDisplay(_INTL("{2} has been identified as a {1} type Pokémon.", PBTypes.getName(e1type1), enemyname))
  else
    scene.pbDisplay(_INTL("{3} has been identified as a {1}/{2} type Pokémon.", PBTypes.getName(e1type1), PBTypes.getName(e1type2), enemyname))

    if $game_switches[10] #BADGE 7
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE, false)
        battler.pbIncreaseStat(PBStats::DEFENSE, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF, false)
        battler.pbIncreaseStat(PBStats::SPDEF, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[8] #BADGE 5
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[6] #BADGE 3
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 2, true)
      end
    elsif $game_switches[8] #BADGE 1
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 1, true)
      end
    end

    return true
  end
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  if useLantern()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:LANTERN, proc { |item|
  Kernel.pbMessage(_INTL("#{$Trainer.name} used the lantern."))
  if useLantern()
    next 1
  else
    next 0
  end
})

def useLantern()
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed? || $PokemonGlobal.flashUsed
    Kernel.pbMessage(_INTL("It's already illuminated..."))
    return false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the cave!"))
  $PokemonGlobal.flashUsed = true
  darkness.radius += 176
  return true
end

ItemHandlers::UseFromBag.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:TELEPORTER, proc { |item|
  if useTeleporter()
    next 1
  else
    next 0
  end
})

def useTeleporter()
  if HiddenMoveHandlers.triggerCanUseMove(:TELEPORT, 0)
    Kernel.pbMessage(_INTL("Teleport to where?", $Trainer.name))
    scene = PokemonRegionMapScene.new(-1, false)
    screen = PokemonRegionMap.new(scene)
    ret = screen.pbStartFlyScreen
    if ret
      $PokemonTemp.flydata = ret
    end
  end

  if !$PokemonTemp.flydata
    return false
  else
    Kernel.pbMessage(_INTL("{1} used the teleporter!", $Trainer.name))
    pbFadeOutIn(99999) {
      Kernel.pbCancelVehicles
      $game_temp.player_new_map_id = $PokemonTemp.flydata[0]
      $game_temp.player_new_x = $PokemonTemp.flydata[1]
      $game_temp.player_new_y = $PokemonTemp.flydata[2]
      $PokemonTemp.flydata = nil
      $game_temp.player_new_direction = 2
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    }
    pbEraseEscapePoint
    return true
  end
end

ItemHandlers::BattleUseOnBattler.add(:POKEDEX, proc { |item, battler, scene|
  #if battler.battle.battlers.length  > -1
  #  scene.pbDisplay(_INTL(" The length is {1}",battler.battle.battlers.length))
  #     scene.pbDisplay(_INTL("The PokéDex cannot be used on multiple enemies at once!"))
  #     return false
  #end

  doublebattle = false
  #DOUBLE BATTLES A FAIRE
  #variable temporaire doublebattle
  if doublebattle
    e = battler.pbOpposing2
  else
    is_trainer = battler.battle.opponent

    e1 = battler.pbOpposing1.pokemon
    enemyname = e1.name
    e1type1 = e1.type1
    e1type2 = e1.type2
  end
  if e1type1 == e1type2
    scene.pbDisplay(_INTL("{2} has been identified as a {1} type Pokémon.", PBTypes.getName(e1type1), enemyname))
  else
    scene.pbDisplay(_INTL("{3} has been identified as a {1}/{2} type Pokémon.", PBTypes.getName(e1type1), PBTypes.getName(e1type2), enemyname))

    if $game_switches[10] #BADGE 7
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE, false)
        battler.pbIncreaseStat(PBStats::DEFENSE, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF, false)
        battler.pbIncreaseStat(PBStats::SPDEF, 1, true)
      end
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[8] #BADGE 5
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 3, true)
      end
    elsif $game_switches[6] #BADGE 3
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 2, true)
      end
    elsif $game_switches[8] #BADGE 1
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY, false)
        battler.pbIncreaseStat(PBStats::ACCURACY, 1, true)
      end
    end

    return true
  end
})

ItemHandlers::UseInBattle.add(:POKEDOLL, proc { |item, battler, battle|
  battle.decision = 3
  battle.pbDisplayPaused(_INTL("Got away safely!"))
})

ItemHandlers::UseFromBag.add(:LANTERN, proc { |item|
  darkness = $PokemonTemp.darknessSprite
  if !darkness || darkness.disposed?
    Kernel.pbMessage(_INTL("The cave is already illuminated."))
    return false
  end
  Kernel.pbMessage(_INTL("The Lantern illuminated the cave!"))
  $PokemonGlobal.flashUsed = true
  darkness.radius += 176
  #while darkness.radius<176
  #  Graphics.update
  #  Input.update
  #  pbUpdateSceneMap
  #  darkness.radius+=4
  #end
  return true
})

ItemHandlers::UseFromBag.add(:AZUREFLUTE, proc { |item|
  if Kernel.pbConfirmMessage(_INTL("Play the Azure Flute?"))
    Kernel.pbMessage(_INTL("You blew into the Azure Flute."))
    if $game_map.map_id == 694
      Kernel.pbMessage(_INTL("A strange sound echoed from the sky..."))
      $game_switches[469] = true
      next true
    else
      Kernel.pbMessage(_INTL("But nothing happened..."))
      next false
    end
    #Kernel.pbMessage(_INTL("{1} was transported somewhere...",$Trainer.name))
    #Kernel.pbTransfer(376,14,51)
  end
  return false
})

ItemHandlers::UseOnPokemon.add(:TRANSGENDERSTONE, proc { |item, pokemon, scene|
  if pokemon.gender == 0
    pokemon.makeFemale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became female!"))
    next true
  elsif pokemon.gender == 1
    pokemon.makeMale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became male!"))

    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  abil1 = 0; abil2 = 0
  for i in abilityList
    abil1 = i[0] if i[1] == 0
    abil2 = i[1] if i[1] == 1
  end
  if poke.abilityIndex() >= 2 || abil1 == abil2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessage(_INTL("Do you want to change {1}'s ability?",
                                   poke.name))

    if poke.abilityIndex() == 0
      poke.setAbility(1)
    else
      poke.setAbility(0)
    end
    scene.pbDisplay(_INTL("{1}'s ability was changed!", poke.name))
    next true
  end
  next false

})

#NOT FULLY IMPLEMENTED
ItemHandlers::UseOnPokemon.add(:SECRETCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  numAbilities = abilityList[0].length

  if numAbilities <= 2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif abilityList[0].length <= 3
    if changeHiddenAbility1(abilityList, scene, poke)
      next true
    end
    next false
  else
    if changeHiddenAbility2(abilityList, scene, poke)
      next true
    end
    next false
  end
})

def changeHiddenAbility1(abilityList, scene, poke)
  abID1 = abilityList[0][2]
  msg = _INTL("Change {1}'s ability to {2}?", poke.name, PBAbilities.getName(abID1))
  if Kernel.pbConfirmMessage(_INTL(msg))
    poke.setAbility(2)
    abilName1 = PBAbilities.getName(abID1)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, PBAbilities.getName(abID1)))
    return true
  else
    return false
  end
end

def changeHiddenAbility2(abilityList, scene, poke)
  return false if !Kernel.pbConfirmMessage(_INTL("Change {1}'s ability?", poke.name))

  abID1 = abilityList[0][2]
  abID2 = abilityList[0][3]

  abilName2 = PBAbilities.getName(abID1)
  abilName3 = PBAbilities.getName(abID2)

  if (Kernel.pbMessage("Choose an ability.", [_INTL("{1}", abilName2), _INTL("{1}", abilName3)], 2)) == 0
    poke.setAbility(2)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName2))
  else
    return false
  end
  poke.setAbility(3)
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName3))
  return true
end

ItemHandlers::UseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, pokemon, scene|
  if pokemon.isEgg?
    if pokemon.eggsteps <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.eggsteps = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, pokemon, scene|
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

def pbForceEvo(pokemon)
  newspecies = getEvolvedSpecies(pokemon)
  return false if newspecies == -1
  if newspecies > 0
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon, newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
  return true
end

def getEvolvedSpecies(pokemon)
  return pbCheckEvolutionEx(pokemon) { |pokemon, evonib, level, poke|
    next pbMiniCheckEvolution(pokemon, evonib, level, poke, true)
  }
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNAREVERSER, proc { |item, pokemon, scene|
  if pokemon.species <= CONST_NB_POKE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    body = getBasePokemonID(pokemon.species, true)
    head = getBasePokemonID(pokemon.species, false)
    newspecies = (head) * CONST_NB_POKE + body

    #play animation
    pbFadeOutInWithMusic(99999) {
      fus = PokemonEvolutionScene.new
      fus.pbStartScreen(pokemon, newspecies, true)
      fus.pbEvolution(false, true)
      fus.pbEndScreen
      #fus.pbStartScreen(pokemon,newspecies,1)
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end

  next false
})

def pbDNASplicing(pokemon, scene, supersplicers = false, superSplicer = false)
  if (pokemon.species <= NB_POKEMON)
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        return false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.form = 0
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        return true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if (poke2.species <= NB_POKEMON) && poke2 != pokemon
          #check if fainted
          if pokemon.hp == 0 || poke2.hp == 0
            scene.pbDisplay(_INTL("A fainted Pokémon cannot be fused!"))
            return false
          end
          if pbFuse(pokemon, poke2, supersplicers)
            pbRemovePokemonAt(chosen)
          end
        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
          return false
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
          return false

        end

      else
        return false
      end
    end
  else
    return true if pbUnfuse(pokemon, scene, supersplicers)

    #unfuse
  end
end

def pbUnfuse(pokemon, scene, supersplicers, pcPosition = nil)
  #pcPosition nil   : unfusing from party
  #pcPosition [x,x] : unfusing from pc
  #

  if (pokemon.obtainMode == 2 || pokemon.ot != $Trainer.name) # && !canunfuse
    scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
    return false
  else
    if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be unfused?", pokemon.name))
      if pokemon.species > (NB_POKEMON * NB_POKEMON) + NB_POKEMON #triple fusion
        scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
        return false
      elsif $Trainer.party.length >= 6 && !pcPosition
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        return false
      else
        scene.pbDisplay(_INTL("Unfusing ... "))
        scene.pbDisplay(_INTL(" ... "))
        scene.pbDisplay(_INTL(" ... "))

        bodyPoke = getBasePokemonID(pokemon.species, true)
        headPoke = getBasePokemonID(pokemon.species, false)
        # pf = pokemon.species
        # p1 = (pf/NB_POKEMON).round
        # p2 = pf - (NB_POKEMON*p1)

        if pokemon.level > 1
          if supersplicers
            lev = pokemon.level * 0.9
          else
            lev = pokemon.obtainMode == 2 ? pokemon.level * 0.65 : pokemon.level * 0.75
          end
        else
          lev = 1
        end
        poke1 = PokeBattle_Pokemon.new(bodyPoke, lev, $Trainer)
        poke2 = PokeBattle_Pokemon.new(headPoke, lev, $Trainer)

        if pcPosition == nil
          box = pcPosition[0]
          index = pcPosition[1]
          $PokemonStorage.pbStoreToBox(poke2, box, index)
        else
          Kernel.pbAddPokemonSilent(poke2, poke2.level)
        end
        #On ajoute l'autre dans le pokedex aussi
        $Trainer.seen[poke1.species] = true
        $Trainer.owned[poke1.species] = true
        $Trainer.seen[poke2.species] = true
        $Trainer.owned[poke2.species] = true

        pokemon.species = poke1.species
        pokemon.level = poke1.level
        pokemon.name = poke1.name
        pokemon.moves = poke1.moves
        pokemon.obtainMode = 0
        poke1.obtainMode = 0

        #scene.pbDisplay(_INTL(p1.to_s + " " + p2.to_s))
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("Your Pokémon were successfully unfused! "))
        return true
      end
    end
  end
end

def pbFuse(pokemon, poke2, supersplicers = false)
  newid = (pokemon.species) * NB_POKEMON + poke2.species
  playingBGM = $game_system.getPlayingBGM

  pathCustom = _INTL("Graphics/CustomBattlers/{1}.{2}.png", poke2.species, pokemon.species)
  #pbResolveBitmap(pathCustom) && $game_variables[196]==0 ? pathCustom : pathReg
  hasCustom = false
  if (pbResolveBitmap(pathCustom))
    picturePath = pathCustom
    hasCustom = true
  else
    picturePath = _INTL("Graphics/Battlers/{1}/{1}.{2}.png", poke2.species, pokemon.species)
  end

  previewwindow = PictureWindow.new(picturePath)

  if hasCustom
    previewwindow.picture.pbSetColor(0, 255, 255, 200)
  else
    previewwindow.picture.pbSetColor(255, 255, 255, 200)
  end
  previewwindow.x = (Graphics.width / 2) - (previewwindow.width / 2)
  previewwindow.y = ((Graphics.height - 96) / 2) - (previewwindow.height / 2)
  previewwindow.z = 1000000

  if (Kernel.pbConfirmMessage(_INTL("Fuse the two Pokémon?", newid)))
    previewwindow.dispose
    fus = PokemonFusionScene.new
    if (fus.pbStartScreen(pokemon, poke2, newid))
      returnItemsToBag(pokemon, poke2)
      fus.pbFusionScreen(false, supersplicers)
      $game_variables[126] += 1 #fuse counter
      fus.pbEndScreen
      scene.pbHardRefresh
      pbBGMPlay(playingBGM)
      return true
    end
  else
    previewwindow.dispose
    return false
  end

end

ItemHandlers::UseOnPokemon.add(:SUPERSPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
})

def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item
  if it1 != nil
    $PokemonBag.pbStoreItem(it1, 1)
  end
  if it2 != nil
    $PokemonBag.pbStoreItem(it2, 1)
  end
  pokemon.item = nil
  poke2.item = nil
end

#A AJOUTER: l'attribut dmgup ne modifie presentement pas
#           le damage d'une attaque
# 
ItemHandlers::UseOnPokemon.add(:DAMAGEUP, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost Damage of which move?"))
  if move >= 0
    #if pokemon.moves[move].damage==0 ||  pokemon.moves[move].accuracy<=5 || pokemon.moves[move].dmgup >=3  
    #  scene.pbDisplay(_INTL("It won't have any effect."))
    #  next false
    #else
    #pokemon.moves[move].dmgup+=1
    #pokemon.moves[move].damage +=5
    #pokemon.moves[move].accuracy -=5

    #movename=PBMoves.getName(pokemon.moves[move].id)
    #scene.pbDisplay(_INTL("{1}'s damage increased.",movename))
    #next true
    scene.pbDisplay(_INTL("This item has not been implemented into the game yet. It had no effect."))
    next false
    #end
  end
})

##New "stones"
ItemHandlers::UseOnPokemon.add(:UPGRADE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:DUBIOUSDISC, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:ICESTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:MAGNETSTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

#easter egg for evolving shellder into slowbro's tail
ItemHandlers::UseOnPokemon.add(:SLOWPOKETAIL, proc { |item, pokemon, scene|
  shellbroNum = NB_POKEMON * PBSpecies::SHELLDER + PBSpecies::SLOWBRO #SHELLBRO
  newspecies = pokemon.species == PBSpecies::SHELLDER ? shellbroNum : -1
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:SHINYSTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:DAWNSTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

#TRACKER (for roaming legendaries)
ItemHandlers::UseInField.add(:REVEALGLASS, proc { |item|
  if RoamingSpecies.length == 0
    Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
  else
    text = "\\l[8]"
    min = $game_switches[350] ? 0 : 1
    for i in min...RoamingSpecies.length
      poke = RoamingSpecies[i]
      next if poke == PBSPecies::FEEBAS
      if $game_switches[poke[2]]
        status = $PokemonGlobal.roamPokemon[i]
        if status == true
          if $PokemonGlobal.roamPokemonCaught[i]
            text += _INTL("{1} has been caught.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          else
            text += _INTL("{1} has been defeated.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          end
        else
          curmap = $PokemonGlobal.roamPosition[i]
          if curmap
            mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")

            if curmap == $game_map.map_id
              text += _INTL("Beep beep! {1} appears to be nearby!",
                            PBSpecies.getName(getID(PBSpecies, poke[0])))
            else
              text += _INTL("{1} is roaming around {3}",
                            PBSpecies.getName(getID(PBSpecies, poke[0])), curmap,
                            mapinfos[curmap].name, (curmap == $game_map.map_id) ? _INTL("(this route!)") : "")
            end
          else
            text += _INTL("{1} is roaming in an unknown area.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])), poke[1])
          end
        end
      else
        #text+=_INTL("{1} does not appear to be roaming.",
        #   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],poke[2])
      end
      text += "\n" if i < RoamingSpecies.length - 1
    end
    Kernel.pbMessage(text)
  end
})

####EXP. ALL
#Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc 
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})

ItemHandlers::UseFromBag.add(:AZUREFLUTE, proc { |item|
  if Kernel.pbConfirmMessage(_INTL("Play the Azure Flute?"))
    Kernel.pbMessage(_INTL("You blew into the Azure Flute."))
    if pbGet(222) >= 30 #if very good karma
      Kernel.pbMessage(_INTL("A strange sound echoed from the sky..."))
      Kernel.pbMessage(_INTL("{1} was transported somewhere...", $Trainer.name))
      Kernel.pbTransfer(376, 14, 51)
      next true
    else
      Kernel.pbMessage(_INTL("But nothing happened..."))
      next false
    end

  end
  return false
})

ItemHandlers::UseOnPokemon.add(:TRANSGENDERSTONE, proc { |item, pokemon, scene|
  if pokemon.gender == 0
    pokemon.makeFemale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became female!"))
    next true
  elsif pokemon.gender == 1
    pokemon.makeMale
    scene.pbRefresh
    scene.pbDisplay(_INTL("The Pokémon became male!"))

    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  abil1 = 0; abil2 = 0
  for i in abilityList
    abil1 = i[0] if i[1] == 0
    abil2 = i[1] if i[1] == 1
  end
  if poke.abilityIndex() >= 2 || abil1 == abil2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessage(_INTL("Do you want to change {1}'s ability?",
                                   poke.name))

    if poke.abilityIndex() == 0
      poke.setAbility(1)
    else
      poke.setAbility(0)
    end
    scene.pbDisplay(_INTL("{1}'s ability was changed!", poke.name))
    next true
  end
  next false

})

#NOT FULLY IMPLEMENTED
ItemHandlers::UseOnPokemon.add(:SECRETCAPSULE, proc { |item, poke, scene|
  abilityList = poke.getAbilityList
  numAbilities = abilityList[0].length

  if numAbilities <= 2
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif abilityList[0].length <= 3
    if changeHiddenAbility1(abilityList, scene, poke)
      next true
    end
    next false
  else
    if changeHiddenAbility2(abilityList, scene, poke)
      next true
    end
    next false
  end
})

def changeHiddenAbility1(abilityList, scene, poke)
  abID1 = abilityList[0][2]
  msg = _INTL("Change {1}'s ability to {2}?", poke.name, PBAbilities.getName(abID1))
  if Kernel.pbConfirmMessage(_INTL(msg))
    poke.setAbility(2)
    abilName1 = PBAbilities.getName(abID1)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, PBAbilities.getName(abID1)))
    return true
  else
    return false
  end
end

def changeHiddenAbility2(abilityList, scene, poke)
  return false if !Kernel.pbConfirmMessage(_INTL("Change {1}'s ability?", poke.name))

  abID1 = abilityList[0][2]
  abID2 = abilityList[0][3]

  abilName2 = PBAbilities.getName(abID1)
  abilName3 = PBAbilities.getName(abID2)

  if (Kernel.pbMessage("Choose an ability.", [_INTL("{1}", abilName2), _INTL("{1}", abilName3)], 2)) == 0
    poke.setAbility(2)
    scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName2))
  else
    return false
  end
  poke.setAbility(3)
  scene.pbDisplay(_INTL("{1}'s ability was changed to {2}!", poke.name, abilName3))
  return true
end

ItemHandlers::UseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ROCKETMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 100, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:FANCYMEAL, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:RAGECANDYBAR, proc { |item, pokemon, scene|
  if pokemon.level <= 1
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbChangeLevel(pokemon, pokemon.level - 1, scene)
    scene.pbHardRefresh
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR, proc { |item, pokemon, scene|
  if pokemon.isEgg?
    if pokemon.eggsteps <= 1
      scene.pbDisplay(_INTL("The egg is already ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("Your egg is ready to hatch!"))
      pokemon.eggsteps = 1
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:INCUBATOR_NORMAL, proc { |item, pokemon, scene|
  if pokemon.isEgg?
    steps = pokemon.eggsteps
    steps -= 2000 / (pokemon.nbIncubatorsUsed + 1).ceil
    if steps <= 1
      pokemon.eggsteps = 1
    else
      pokemon.eggsteps = steps
    end
    if pokemon.eggsteps <= 1
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("The egg is ready to hatch!"))
      next false
    else
      scene.pbDisplay(_INTL("Incubating..."))
      scene.pbDisplay(_INTL("..."))
      scene.pbDisplay(_INTL("..."))
      if pokemon.nbIncubatorsUsed >= 10
        scene.pbDisplay(_INTL("The egg is a bit closer to hatching"))
      else
        scene.pbDisplay(_INTL("The egg is closer to hatching"))
      end
      pokemon.incrIncubator()
      next true
    end
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

ItemHandlers::UseOnPokemon.add(:MISTSTONE, proc { |item, pokemon, scene|
  if pbForceEvo(pokemon)
    next true
  else
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
})

def pbForceEvo(pokemon)
  newspecies = getEvolvedSpecies(pokemon)
  return false if newspecies == -1
  if newspecies > 0
    evo = PokemonEvolutionScene.new
    evo.pbStartScreen(pokemon, newspecies)
    evo.pbEvolution
    evo.pbEndScreen
  end
  return true
end

def getEvolvedSpecies(pokemon)
  return pbCheckEvolutionEx(pokemon) { |pokemon, evonib, level, poke|
    next pbMiniCheckEvolution(pokemon, evonib, level, poke, true)
  }
end

#(copie de fixEvolutionOverflow dans FusionScene)
def getCorrectEvolvedSpecies(pokemon)
  if pokemon.species >= NB_POKEMON
    body = getBasePokemonID(pokemon.species)
    head = getBasePokemonID(pokemon.species, false)
    ret1 = -1; ret2 = -1
    for form in pbGetEvolvedFormData(body)
      retB = yield pokemon, form[0], form[1], form[2]
      break if retB > 0
    end
    for form in pbGetEvolvedFormData(head)
      retH = yield pokemon, form[0], form[1], form[2]
      break if retH > 0
    end
    return ret if ret == retB && ret == retH
    return fixEvolutionOverflow(retB, retH, pokemon.species)
  else
    for form in pbGetEvolvedFormData(pokemon.species)
      newspecies = form[2]
    end
    return newspecies;
  end

end

#########################
##  DNA SPLICERS  #######
#########################

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene)
  next false
})

ItemHandlers::UseOnPokemon.add(:INFINITESPLICERS2, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNASPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene)
  next false
})

ItemHandlers::UseOnPokemon.add(:DNAREVERSER, proc { |item, pokemon, scene|
  if pokemon.species <= CONST_NB_POKE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    body = getBasePokemonID(pokemon.species, true)
    head = getBasePokemonID(pokemon.species, false)
    newspecies = (head) * CONST_NB_POKE + body

    #play animation
    pbFadeOutInWithMusic(99999) {
      fus = PokemonEvolutionScene.new
      fus.pbStartScreen(pokemon, newspecies, true)
      fus.pbEvolution(false, true)
      fus.pbEndScreen
      #fus.pbStartScreen(pokemon,newspecies,1)
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end

  next false
})

ItemHandlers::UseOnPokemon.add(:INFINITEREVERSERS, proc { |item, pokemon, scene|
  if pokemon.species <= CONST_NB_POKE
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be reversed?", pokemon.name))
    body = getBasePokemonID(pokemon.species, true)
    head = getBasePokemonID(pokemon.species, false)
    newspecies = (head) * CONST_NB_POKE + body

    #play animation
    pbFadeOutInWithMusic(99999) {
      fus = PokemonEvolutionScene.new
      fus.pbStartScreen(pokemon, newspecies, true)
      fus.pbEvolution(false, true)
      fus.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end

  next false
})

def pbDNASplicing(pokemon, scene, supersplicers = false, superSplicer = false)
  playingBGM = $game_system.getPlayingBGM
  dexNumber = pokemon.species_data.id_number
  if (pokemon.species_data.id_number <= NB_POKEMON)
    if pokemon.fused != nil
      if $Trainer.party.length >= 6
        scene.pbDisplay(_INTL("Your party is full! You can't unfuse {1}.", pokemon.name))
        return false
      else
        $Trainer.party[$Trainer.party.length] = pokemon.fused
        pokemon.fused = nil
        pokemon.form = 0
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pokemon.name))
        return true
      end
    else
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      if chosen >= 0
        poke2 = $Trainer.party[chosen]
        if (poke2.species_data.id_number <= NB_POKEMON) && poke2 != pokemon
          #check if fainted
          if pokemon.hp == 0 || poke2.hp == 0
            scene.pbDisplay(_INTL("A fainted Pokémon cannot be fused!"))
            return false
          end

          newid = (pokemon.species_data.id_number) * NB_POKEMON + poke2.species_data.id_number

          pathCustom = _INTL("Graphics/CustomBattlers/{1}.{2}.png", poke2.species_data.id_number, pokemon.species_data.id_number)
          #pbResolveBitmap(pathCustom) && $game_variables[196]==0 ? pathCustom : pathReg
          hasCustom = false
          if (pbResolveBitmap(pathCustom))
            picturePath = pathCustom
            hasCustom = true
          else
            picturePath = _INTL("Graphics/Battlers/{1}/{1}.{2}.png", poke2.species_data.id_number, pokemon.species_data.id_number)
          end

          previewwindow = PictureWindow.new(picturePath)

          if hasCustom
            previewwindow.picture.pbSetColor(220, 255, 220, 200)
          else
            previewwindow.picture.pbSetColor(255, 255, 255, 200)
          end
          previewwindow.x = (Graphics.width / 2) - (previewwindow.width / 2)
          previewwindow.y = ((Graphics.height - 96) / 2) - (previewwindow.height / 2)
          previewwindow.z = 1000000

          if (Kernel.pbConfirmMessage(_INTL("Fuse the two Pokémon?", newid)))
            previewwindow.dispose
            fus = PokemonFusionScene.new
            if (fus.pbStartScreen(pokemon, poke2, newid))
              returnItemsToBag(pokemon, poke2)
              fus.pbFusionScreen(false, supersplicers)
              $game_variables[126] += 1 #fuse counter
              pbRemovePokemonAt(chosen)
              fus.pbEndScreen
              scene.pbHardRefresh
              pbBGMPlay(playingBGM)
              return true

            end
          else
            previewwindow.dispose
            return false
          end

        elsif pokemon == poke2
          scene.pbDisplay(_INTL("{1} can't be fused with itself!", pokemon.name))
          return false
        else
          scene.pbDisplay(_INTL("{1} can't be fused with {2}.", poke2.name, pokemon.name))
          return false

        end
      else
        return false
      end
    end
  else
    #UNFUSE

    bodyPoke = getBasePokemonID(pokemon.species_data.id_number, true)
    headPoke = getBasePokemonID(pokemon.species_data.id_number, false)

    if (pokemon.obtainMode == 2 || pokemon.ot != $Trainer.name) # && !canunfuse
      scene.pbDisplay(_INTL("You can't unfuse a Pokémon obtained in a trade!"))
      return false
    else
      if Kernel.pbConfirmMessageSerious(_INTL("Should {1} be unfused?", pokemon.name))
        if pokemon.species_data.id_number > (NB_POKEMON * NB_POKEMON) + NB_POKEMON #triple fusion
          scene.pbDisplay(_INTL("{1} cannot be unfused.", pokemon.name))
          return false
        end

        keepInParty = 0
        if $Trainer.party.length >= 6
          scene.pbDisplay(_INTL("Your party is full! Keep which Pokémon in party?"))
          choice = Kernel.pbMessage("Select a Pokémon to keep in your party.", [_INTL("{1}", PBSpecies.getName(bodyPoke)), _INTL("{1}", PBSpecies.getName(headPoke)), "Cancel"], 2)
          if choice == 2
            return false
          else
            keepInParty = choice
          end
        end

        scene.pbDisplay(_INTL("Unfusing ... "))
        scene.pbDisplay(_INTL(" ... "))
        scene.pbDisplay(_INTL(" ... "))

        # pf = pokemon.species
        # p1 = (pf/NB_POKEMON).round
        # p2 = pf - (NB_POKEMON*p1)

        if pokemon.level > 1
          if supersplicers
            lev = pokemon.level * 0.9
          else
            lev = pokemon.obtainMode == 2 ? pokemon.level * 0.65 : pokemon.level * 0.80
          end
        else
          lev = 1
        end
        poke1 = PokeBattle_Pokemon.new(bodyPoke, lev, $Trainer)
        poke2 = PokeBattle_Pokemon.new(headPoke, lev, $Trainer)

        if $Trainer.party.length >= 6
          if (keepInParty == 0)
            $PokemonStorage.pbStoreCaught(poke2)
            scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
          else
            poke2 = PokeBattle_Pokemon.new(bodyPoke, lev, $Trainer)
            poke1 = PokeBattle_Pokemon.new(headPoke, lev, $Trainer)

            $PokemonStorage.pbStoreCaught(poke2)
            scene.pbDisplay(_INTL("{1} was sent to the PC.", poke2.name))
          end
        else
          Kernel.pbAddPokemonSilent(poke2, poke2.level)
        end

        #On ajoute l'autre dans le pokedex aussi
        $Trainer.seen[poke1.species] = true
        $Trainer.owned[poke1.species] = true

        pokemon.species = poke1.species
        pokemon.level = poke1.level
        pokemon.name = poke1.name
        pokemon.moves = poke1.moves
        pokemon.obtainMode = 0
        poke1.obtainMode = 0

        #scene.pbDisplay(_INTL(p1.to_s + " " + p2.to_s))
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("Your Pokémon were successfully unfused! "))
        return true
      end
    end
  end
end

ItemHandlers::UseOnPokemon.add(:SUPERSPLICERS, proc { |item, pokemon, scene|
  next true if pbDNASplicing(pokemon, scene, true, true)
})

def returnItemsToBag(pokemon, poke2)

  it1 = pokemon.item
  it2 = poke2.item

  $PokemonBag.pbStoreItem(it1, 1) if it1 != nil
  $PokemonBag.pbStoreItem(it2, 1) if it2 != nil

  pokemon.item = nil
  poke2.item = nil
end

#A AJOUTER: l'attribut dmgup ne modifie presentement pas
#           le damage d'une attaque
# 
ItemHandlers::UseOnPokemon.add(:DAMAGEUP, proc { |item, pokemon, scene|
  move = scene.pbChooseMove(pokemon, _INTL("Boost Damage of which move?"))
  if move >= 0
    #if pokemon.moves[move].damage==0 ||  pokemon.moves[move].accuracy<=5 || pokemon.moves[move].dmgup >=3  
    #  scene.pbDisplay(_INTL("It won't have any effect."))
    #  next false
    #else
    #pokemon.moves[move].dmgup+=1
    #pokemon.moves[move].damage +=5
    #pokemon.moves[move].accuracy -=5

    #movename=PBMoves.getName(pokemon.moves[move].id)
    #scene.pbDisplay(_INTL("{1}'s damage increased.",movename))
    #next true
    scene.pbDisplay(_INTL("This item has not been implemented into the game yet. It had no effect."))
    next false
    #end
  end
})

##New "stones"
ItemHandlers::UseOnPokemon.add(:UPGRADE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:DUBIOUSDISC, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:ICESTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:MAGNETSTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:SHINYSTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

ItemHandlers::UseOnPokemon.add(:DAWNSTONE, proc { |item, pokemon, scene|
  if (pokemon.isShadow? rescue false)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newspecies = pbCheckEvolution(pokemon, item)
  if newspecies <= 0
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  else
    pbFadeOutInWithMusic(99999) {
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pokemon, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
      scene.pbRefreshAnnotations(proc { |p| pbCheckEvolution(p, item) > 0 })
      scene.pbRefresh
    }
    next true
  end
})

#
# ItemHandlers::UseOnPokemon.copy(:FIRESTONE,
#    :THUNDERSTONE,:WATERSTONE,:LEAFSTONE,:MOONSTONE,
#    :SUNSTONE,:DUSKSTONE,:DAWNSTONE,:SHINYSTONE,:OVALSTONE,
#    :UPGRADE,:DUBIOUSDISC,:ICESTONE,:MAGNETSTONE)

#Quest log

ItemHandlers::UseFromBag.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
  next 1
})

ItemHandlers::UseInField.add(:DEVONSCOPE, proc { |item|
  pbQuestlog()
})

#TRACKER (for roaming legendaries)
ItemHandlers::UseInField.add(:REVEALGLASS, proc { |item|
  nbRoaming = 0
  if RoamingSpecies.length == 0
    Kernel.pbMessage(_INTL("No roaming Pokémon defined."))
  else
    text = "\\l[8]"
    min = $game_switches[350] ? 0 : 1
    for i in min...RoamingSpecies.length
      poke = RoamingSpecies[i]
      next if poke[0] == :FEEBAS
      if $game_switches[poke[2]]
        status = $PokemonGlobal.roamPokemon[i]
        if status == true
          if $PokemonGlobal.roamPokemonCaught[i]
            text += _INTL("{1} has been caught.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          else
            text += _INTL("{1} has been defeated.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])))
          end
        else
          nbRoaming += 1
          curmap = $PokemonGlobal.roamPosition[i]
          if curmap
            mapinfos = $RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")

            if curmap == $game_map.map_id
              text += _INTL("Beep beep! {1} appears to be nearby!",
                            PBSpecies.getName(getID(PBSpecies, poke[0])))
            else
              text += _INTL("{1} is roaming around {3}",
                            PBSpecies.getName(getID(PBSpecies, poke[0])), curmap,
                            mapinfos[curmap].name, (curmap == $game_map.map_id) ? _INTL("(this route!)") : "")
            end
          else
            text += _INTL("{1} is roaming in an unknown area.",
                          PBSpecies.getName(getID(PBSpecies, poke[0])), poke[1])
          end
        end
      else
        #text+=_INTL("{1} does not appear to be roaming.",
        #   PBSpecies.getName(getID(PBSpecies,poke[0])),poke[1],poke[2])
      end
      text += "\n" if i < RoamingSpecies.length - 1
    end
    if nbRoaming == 0
      text = "No Pokémon appears to be roaming at this moment."
    end
    Kernel.pbMessage(text)
  end
})

####EXP. ALL
#Methodes relative a l'exp sont pas encore la et pas compatibles
# avec cette version de essentials donc 
# ca fait fuck all pour l'instant.
ItemHandlers::UseFromBag.add(:EXPALL, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALL, :EXPALLOFF)
  Kernel.pbMessage(_INTL("The Exp All was turned off."))
  $game_switches[920] = false
  next 1 # Continue
})

ItemHandlers::UseFromBag.add(:EXPALLOFF, proc { |item|
  $PokemonBag.pbChangeItem(:EXPALLOFF, :EXPALL)
  Kernel.pbMessage(_INTL("The Exp All was turned on."))
  $game_switches[920] = true
  next 1 # Continue
})

ItemHandlers::BattleUseOnPokemon.add(:BANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 30, scene)
})
ItemHandlers::UseOnPokemon.add(:BANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 30, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, battler, scene|
  next pbBattleHPItem(pokemon, battler, 50, scene)
})
ItemHandlers::UseOnPokemon.add(:GOLDENBANANA, proc { |item, pokemon, scene|
  next pbHPItem(pokemon, 50, scene)
})