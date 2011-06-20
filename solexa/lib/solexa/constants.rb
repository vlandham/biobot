class Paths
  ADMIN_PATH = "/qcdata/Admin"
  SCRIPT_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "scripts")
  ROOT_PATH = "/solexa"
  BASECALLS_PATH = "/Data/Intensities/BaseCalls"
  TEMPLATE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "assests")

  def self.admin_path
    ADMIN_PATH
  end

  def self.script_path
    SCRIPT_PATH
  end

  def self.root_path
    ROOT_PATH
  end

  def self.basecalls_path
    BASECALLS_PATH
  end

  def self.template_path
    TEMPLATE_PATH
  end
end
