class Paths
  ADMIN_PATH = "/qcdata/Admin"
  CASAVA_BIN_PATH = "~/CASAVA_v1.8.0/bin"
  ROOT_PATH = "/solexa"
  BASECALLS_PATH = "/Data/Intensities/BaseCalls"
  UNALIGNED_PATH = "/Unaligned"
  ALIGNED_PATH = "/Aligned"
  TEMPLATE_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "assests")
  SCRIPT_PATH = File.join(File.expand_path(File.dirname(__FILE__)), "..", "scripts")

  def self.admin_path
    ADMIN_PATH
  end

  def self.script_path
    SCRIPT_PATH
  end

  def self.casava_bin_path
    CASAVA_BIN_PATH
  end

  def self.root_path
    ROOT_PATH
  end

  def self.basecalls_path
    BASECALLS_PATH
  end

  def self.unaligned_path
    UNALIGNED_PATH
  end

  def self.aligned_path
    ALIGNED_PATH
  end

  def self.template_path
    TEMPLATE_PATH
  end
end
