#===============================================================================
# Battle intro animation
#===============================================================================
def pbSceneStandby
  $scene.disposeSpritesets if $scene.is_a?(Scene_Map)
  if RPG::Cache.need_clearing
    RPG::Cache.clear
  end
  Graphics.frame_reset
  yield
  $scene.createSpritesets if $scene.is_a?(Scene_Map)
end

def pbBattleAnimation(bgm=nil,battletype=0,foe=nil)
  Battle.start bgm, battletype, foe
end

#===============================================================================
# Vs. battle intro animation
#===============================================================================
def pbBattleAnimationOverride(viewport,battletype=0,foe=nil)
  ##### VS. animation, by Luka S.J. #####
  ##### Tweaked by Maruno           #####
  if (battletype==1 || battletype==3) && foe.length==1   # Against single trainer
    tr_type = foe[0].trainer_type
    tr_number= GameData::TrainerType.get(tr_type).id_number


    if tr_type
      tbargraphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
      #tgraphic    = sprintf("vsTrainer_%s", tr_type.to_s) rescue nil
      tgraphic    = sprintf("trainer%03d", tr_number) rescue nil

      echoln tgraphic
      if pbResolveBitmap("Graphics/Transitions/" + tbargraphic) && pbResolveBitmap("Graphics/Characters/" + tgraphic)
        player_tr_type = $Trainer.trainer_type
        outfit = $Trainer.outfit
        # Set up
        viewplayer = Viewport.new(0,Graphics.height/3,Graphics.width/2,128)
        viewplayer.z = viewport.z
        viewopp = Viewport.new(Graphics.width/2,Graphics.height/3,Graphics.width/2,128)
        viewopp.z = viewport.z
        viewvs = Viewport.new(0,0,Graphics.width,Graphics.height)
        viewvs.z = viewport.z
        fade = Sprite.new(viewport)
        fade.bitmap  = RPG::Cache.transition("vsFlash")
        fade.tone    = Tone.new(-255,-255,-255)
        fade.opacity = 100
        overlay = Sprite.new(viewport)
        overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
        pbSetSystemFont(overlay.bitmap)
        #pbargraphic = sprintf("vsBar_%s_%d", player_tr_type.to_s, outfit) rescue nil
        pbargraphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
        if !pbResolveBitmap("Graphics/Transitions/" + pbargraphic)
          pbargraphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
        end
        # xoffset = ((Graphics.width/2)/10)*10
        xoffset = ((Graphics.width/2)/10)*10
        #xoffset = 0#((Graphics.width/2)/10)*10

        bar1 = Sprite.new(viewplayer)
        bar1.bitmap = RPG::Cache.transition(pbargraphic)
        bar1.x      = -xoffset
        bar2 = Sprite.new(viewopp)
        bar2.bitmap = RPG::Cache.transition(tbargraphic)
        bar2.x      = xoffset
        vs = Sprite.new(viewvs)
        vs.bitmap  = RPG::Cache.transition("vs")
        vs.ox      = vs.bitmap.width/2
        vs.oy      = vs.bitmap.height/2
        vs.x       = Graphics.width/2
        vs.y       = Graphics.height/1.5
        vs.visible = false
        flash = Sprite.new(viewvs)
        flash.bitmap  = RPG::Cache.transition("vsFlash")
        flash.opacity = 0
        # Animate bars sliding in from either side
        slideInTime = (Graphics.frame_rate*0.25).floor

        for i in 0...slideInTime
          bar1.x = xoffset*(i+1-slideInTime)/slideInTime
          bar2.x = xoffset*(slideInTime-i-1)/slideInTime
          pbWait(1)
        end
        bar1.dispose
        bar2.dispose
        # Make whole screen flash white
        pbSEPlay("Vs flash")
        pbSEPlay("Vs sword")
        flash.opacity = 255
        # Replace bar sprites with AnimatedPlanes, set up trainer sprites
        bar1 = AnimatedPlane.new(viewplayer)
        bar1.bitmap = RPG::Cache.transition(pbargraphic)
        bar2 = AnimatedPlane.new(viewopp)
        bar2.bitmap = RPG::Cache.transition(tbargraphic)
        #pgraphic = sprintf("vsTrainer_%s_%d", player_tr_type.to_s, outfit) rescue nil
        #pgraphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil

        # pgraphic = generate_front_trainer_sprite_bitmap()#sprintf("trainer%03d", tr_number) rescue nil
        #
        # #if !pbResolveBitmap("Graphics/Transitions/" + pgraphic)
        # if !pbResolveBitmap("Graphics/Characters/" + pgraphic)
        #   pgraphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil
        # end
        player = Sprite.new(viewplayer)
        #player.bitmap = RPG::Cache.transition(tgraphic)
        #
        playerSpriteWrapper = generate_front_trainer_sprite_bitmap()
        player.bitmap = playerSpriteWrapper.bitmap # RPG::Cache.load_bitmap("Graphics/Characters/", pgraphic) #RPG::Cache.transition(pgraphic)
        player.x      =  -250
        player.y = -30
        player.zoom_x = 2
        player.zoom_y = 2

        player.mirror =true
        player_center_offset=-20

        trainer = Sprite.new(viewopp)
        #trainer.bitmap = RPG::Cache.transition(tgraphic)
        trainer.bitmap =RPG::Cache.load_bitmap("Graphics/Characters/", tgraphic) #RPG::Cache.transition(pgraphic)
        trainer.x      = xoffset+150
        trainer.tone   = Tone.new(-255,-255,-255)
        trainer.zoom_x = 2
        trainer.zoom_y = 2
        trainer.y = -10
        trainer_center_offset=0

        # Dim the flash and make the trainer sprites appear, while animating bars
        animTime = (Graphics.frame_rate*1.2).floor
        for i in 0...animTime
          flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
          bar1.ox -= 32*20/Graphics.frame_rate
          bar2.ox += 32*20/Graphics.frame_rate
          if i>=animTime/2 && i<slideInTime+animTime/2
            player.x = (xoffset*(i+1-slideInTime-animTime/2)/slideInTime)+player_center_offset
            trainer.x = xoffset*(slideInTime-i-1+animTime/2)/slideInTime+trainer_center_offset
          end
          pbWait(1)
        end


        echoln  "VS flash"
        #player.x = -150
        #player.y=-75

        #trainer.x = -20
        # trainer.y = -75

        # Make whole screen flash white again
        flash.opacity = 255
        pbSEPlay("Vs sword")
        # Make the Vs logo and trainer names appear, and reset trainer's tone
        vs.visible = true
        trainer.tone = Tone.new(0,0,0)
        trainername = foe[0].name
        textpos = [
          [$Trainer.name,Graphics.width/4,(Graphics.height/1.5)+4,2,
           Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
          [trainername,(Graphics.width/4)+(Graphics.width/2),(Graphics.height/1.5)+4,2,
           Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
        ]
        pbDrawTextPositions(overlay.bitmap,textpos)
        # Fade out flash, shudder Vs logo and expand it, and then fade to black
        animTime = (Graphics.frame_rate*2.75).floor
        shudderTime = (Graphics.frame_rate*1.75).floor
        zoomTime = (Graphics.frame_rate*2.5).floor
        shudderDelta = [4*20/Graphics.frame_rate,1].max
        for i in 0...animTime
          if i<shudderTime   # Fade out the white flash
            flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
          elsif i==shudderTime   # Make the flash black
            flash.tone = Tone.new(-255,-255,-255)
          elsif i>=zoomTime   # Fade to black
            flash.opacity += 52*20/Graphics.frame_rate if flash.opacity<255
          end
          bar1.ox -= 32*20/Graphics.frame_rate
          bar2.ox += 32*20/Graphics.frame_rate
          if i<shudderTime
            j = i%(2*Graphics.frame_rate/20)
            if j>=0.5*Graphics.frame_rate/20 && j<1.5*Graphics.frame_rate/20
              vs.x += shudderDelta
              vs.y -= shudderDelta
            else
              vs.x -= shudderDelta
              vs.y += shudderDelta
            end
          elsif i<zoomTime
            vs.zoom_x += 0.4*20/Graphics.frame_rate
            vs.zoom_y += 0.4*20/Graphics.frame_rate
          end
          pbWait(1)
        end
        # End of animation
        player.dispose
        trainer.dispose
        flash.dispose
        vs.dispose
        bar1.dispose
        bar2.dispose
        overlay.dispose
        fade.dispose
        viewvs.dispose
        viewopp.dispose
        viewplayer.dispose
        viewport.color = Color.new(0,0,0,255)
        return true
      end
    end
  end
  return false
end

#===============================================================================
# Override battle intro animation
#===============================================================================
# If you want to add a custom battle intro animation, copy the following alias
# line and method into a new script section. Change the name of the alias part
# ("__over1__") in your copied code in both places. Then add in your custom
# transition code in the place shown.
# Note that $game_temp.background_bitmap contains an image of the current game
# screen.
# When the custom animation has finished, the screen should have faded to black
# somehow.

alias __over1__pbBattleAnimationOverride pbBattleAnimationOverride

def pbBattleAnimationOverride(viewport,battletype=0,foe=nil)
  # The following example runs a common event that ought to do a custom
  # animation if some condition is true:
  #
  # if $game_map.map_id==20   # If on map 20
  #   pbCommonEvent(20)
  #   return true             # Note that the battle animation is done
  # end
  #
  # The following line needs to call the aliased method if the custom transition
  # animation was NOT shown.
  return __over1__pbBattleAnimationOverride(viewport,battletype,foe)
end
