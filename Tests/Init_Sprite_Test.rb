module Test_Suite
  class Init_Sprite_Test < Test_Scene
    
    @@uuid = "Init_Sprite_Test".freeze

    def test_screen
      viewport = Viewport.new(0, 0, Graphics.width, Graphics.height) 
      background = Sprite.new viewport
      background.bitmap = pbBitmap("Tests/test_scene")
      wait (Graphics.frame_rate * 10)
    end

    def main
      Graphics.transition 0
      test_screen
      Graphics.freeze()
      $scene = nil
    end
   
    def wait frames 
      frames.times do
        Graphics.update
        Input.update
      end
    end
  end
end
