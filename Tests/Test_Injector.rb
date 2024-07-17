def Object.method_added name
  if (name == :pbCallTitle) and !(pbCallTitle().kind_of? Test_Suite::ITest_Scene)
    def pbCallTitle
      return Test_Suite::Test_Scene_Factory.generate_test "Init_Sprite_Test".freeze
    end
  end
end
