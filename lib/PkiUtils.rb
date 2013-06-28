class PkiUtils

  def self.load_key path
    OpenSSL::X509::Certificate.new(File.read(path))
  end

  def self.generate_key
    key = OpenSSL::PKey::RSA.new 2048
    key
  end

end