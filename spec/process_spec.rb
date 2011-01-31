require 'spec/spec_helper'
require 'icuke/waxsim'

describe ICuke::Simulator::Process do

  it "should provide a list of commands necessary to set up the environment" do
    p = ICuke::Simulator::Process.new('foo', {})
    p.should respond_to(:setup_commands)
    p.setup_commands.should be_kind_of(Array)
  end
  
  it "should not provide a defaults command when retina is not specified" do
    found = ICuke::Simulator::Process.new('foo', {}).setup_commands.detect {|c| c =~ /^defaults/}
    found.should be_nil
  end

  it "should set SimulateDevice to \"iPhone (Retina)\" if platform is iPhone and retina is required" do
    attrs = {:platform => :iphone, :retina => true}
    found = ICuke::Simulator::Process.new('foo', attrs).setup_commands.detect {|c| c =~ /^defaults/}
    found.should_not be_nil
    found.should == "defaults write com.apple.iphonesimulator SimulateDevice '\"iPhone (Retina)\"'"
  end

  it "should set SimulateDevice to \"iPhone\" if platform is iPhone and retina is rejected" do
    attrs = {:platform => :iphone, :retina => false}
    found = ICuke::Simulator::Process.new('foo', attrs).setup_commands.detect {|c| c =~ /^defaults/}
    found.should_not be_nil
    found.should == "defaults write com.apple.iphonesimulator SimulateDevice '\"iPhone\"'"
  end

  it "should set SimulateDevice to \"iPad\" if platform is iPad and retina is rejected" do
    attrs = {:platform => :ipad, :retina => false}
    found = ICuke::Simulator::Process.new('foo', attrs).setup_commands.detect {|c| c =~ /^defaults/}
    found.should_not be_nil
    found.should == "defaults write com.apple.iphonesimulator SimulateDevice '\"iPad\"'"
  end

end
