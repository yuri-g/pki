class PkiUtils


  #helper method to load certificate
  def self.load_cert path
    OpenSSL::X509::Certificate.new(File.read(path))
  end


  #helper method to load key
  def self.load_key path
    OpenSSL::PKey::RSA.new(File.read(path))
  end

  def self.generate_key
    OpenSSL::PKey::RSA.new 2048
  end


  #get the csr from keygen element
  def self.get_csr keygen
    csr = OpenSSL::Netscape::SPKI.new(keygen)
    raise 'CSR can not be verified' unless csr.verify csr.public_key
    csr

  end

end