require 'logger'

require_relative "with_stdout/error"
require_relative "with_stdout/multi_io"
require_relative "with_stdout/version"

class Logger
  class WithStdout < ::Logger
    def initialize logdev=nil, options={}
      stdout     = options[:stdout] || true
      stderr     = options[:stderr] || false
      shift_age  = options[:shift_age]  || 0
      shift_size = options[:shift_size] || 1048576

      targets = []
      if logdev
        if logdev.class == String
          targets << File.open(logdev, 'a')
        else
          targets << logdev
        end
      end
      targets << $stdout if (stdout and $stdout.tty?)
      targets << $stderr if (stderr and $stderr.tty?)
      if targets.empty?
        raise Logger::WithStdout::Error, "No output device found!"
      end
      multi_dev = MultiIO.new targets

      super multi_dev, shift_age, shift_size
    end
  end
end