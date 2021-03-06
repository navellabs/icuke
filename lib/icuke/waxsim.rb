require 'background_process'
require 'tmpdir'

module ICuke
  class Simulator
    include Timeout
    
    attr_accessor :current_process
    
    def launch(process)
      process = process.with_options({
        :env => {
          'CFFIXED_USER_HOME' => Dir.mktmpdir
        }
      })

      process.setup_commands.each do |cmd|
        fail "Unable to run setup command #{cmd}" if !system(cmd)
        fail "Setup command #{cmd} failed with exit status #{$?}" if $? != 0
      end

      @simulator = BackgroundProcess.run(process.command)
      self.current_process = process

      timeout(30) do
        begin
          view
        rescue Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError
          sleep(0.5)
          retry
        end
      end
    end
    
    def quit
      get '/quit' rescue nil # results in a hard exit(0)
      @simulator.wait
      self.current_process = nil
    end
    
    def suspend
      @simulator.kill('QUIT') # invokes the normal app exit routine
      @simulator.wait
      sleep 1
    end
    
    def resume
      launch(self.current_process)
    end
    
    class Process
      DEFAULT_CONFIGURATION = 'Debug'
      
      def initialize(project_file, launch_options = {})
        @project_file = project_file
        @launch_options = launch_options
      end
      
      # returns a new Process, treat Process as an immutable value object
      def with_options(options = {})
        self.class.new(@project_file, options.merge(@launch_options))
      end

      def setup_commands
        cmds = []
        cmds << simulate_device_command if @launch_options.has_key?(:retina)
        cmds
      end
      
      def command
        ICuke::SDK.launch("#{directory}/#{target}.app", @launch_options[:platform], @launch_options[:env])
      end
      
      private

      def simulate_device_command
        "defaults write com.apple.iphonesimulator SimulateDevice '\"#{simulate_device}\"'"
      end

      def simulate_device
        case @launch_options[:platform]
        when :ipad
          "iPad"
        else
          "iPhone"
        end +
        if @launch_options[:retina]
          " (Retina)"
        else
          ""
        end
      end
      
      def target
        @launch_options[:target] || File.basename(@project_file, '.xcodeproj')
      end
      
      def build_configuration
        @launch_options[:build_configuration] || DEFAULT_CONFIGURATION
      end
      
      def directory
        "#{File.dirname(@project_file)}/build/#{build_configuration}-iphonesimulator"
      end
    end
  end
end
