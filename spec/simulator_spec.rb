require 'spec/spec_helper'
require 'icuke/waxsim'

describe ICuke::Simulator do

  describe :launch do
    it "should run any setup commands" do
      s = ICuke::Simulator.new
      s.stub(:view).and_return(nil)

      p = ICuke::Simulator::Process.new('foo', {:env => {}})
      f = "/tmp/command_was_run.#{$$}"
      p.stub(:setup_commands).and_return(["touch #{f}"])
      p.stub(:with_options).and_return(p)

      BackgroundProcess.stub(:run).and_return(nil)

      File.delete(f) rescue nil

      ICuke::SDK.use('4.0')
      s.launch(p)

      File.exist?(f).should be_true
      File.delete(f) rescue nil
    end
  end
  
end
