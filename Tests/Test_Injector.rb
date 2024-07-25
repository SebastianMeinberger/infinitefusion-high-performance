#require 'debug'

#module Graphics
#  @@super_update = instance_method(:update)

#  def self.update
#    @@super_update.bind(self).()
    #puts Graphics.average_frame_rate
#  end
#end


def Object.method_added method_symbol
  if (method_symbol == :pbCallTitle) and !pbCallTitle.nil? and !(pbCallTitle().kind_of? Test_Suite::Test_Scene)
    def pbCallTitle
        return Test_Suite::Test_Scene_Factory.generate_test "Pallet_Town_Benchmark".freeze
    end
  end
end
