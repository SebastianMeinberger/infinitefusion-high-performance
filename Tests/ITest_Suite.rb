require 'debug'

module Test_Suite
  class ITest_Scene
    @@uuid = "0".freeze
    
    def self.uuid
      return @@uuid
    end
  end

  class Test_Scene_Factory
    def self.generate_all_tests
      test_scenes = []
      Test_Suite::ITest_Scene.subclasses.each do |test_class|
        test_scenes.push test_class.new
      end

      return test_scenes
    end

    def self.generate_test uuid
      Test_Suite::ITest_Scene.subclasses.each do |test_class|
        if test_class.uuid == uuid
          return test_class.new
        end
      end
    end
  end
end
