$TESTING=true

require 'simplecov'
SimpleCov.start do
  add_group 'Libraries', 'lib'
  add_group 'Specs', 'spec'
end

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require 'solexa'
require 'stringio'

require 'rdoc'
require 'rspec'

# Load fixtures
#load File.join(File.dirname(__FILE__), "fixtures", "pipe.thor")

class Paths
  TEST_ROOT_PATH = File.join(File.dirname(__FILE__), "test_root")
  def self.root_path
    TEST_ROOT_PATH
  end
end

VALID_FLOWCELL = "639N6AAXX"
INVALID_FLOWCELL = "123AAXX"

RSpec.configure do |config|
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def source_root
    File.join(File.dirname(__FILE__), 'fixtures')
  end

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end

  alias :silence :capture
end

