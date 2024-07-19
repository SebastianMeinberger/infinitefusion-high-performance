require 'debug'
def Object.method_added method_symbol
  if (method_symbol == :pbCallTitle) and !pbCallTitle.nil? and !(pbCallTitle().kind_of? Test_Suite::ITest_Scene)
    def pbCallTitle
        return Test_Suite::Test_Scene_Factory.generate_test "Pallet_Town_Benchmark".freeze
    end
  end
end
