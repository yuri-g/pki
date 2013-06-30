class CertificateService

  def initialize root_cert, root_key
    @root_cert = root_cert
    @root_key = root_key
  end


  #generates and signs the certificate
  def generate params, csr
    csr_cert = OpenSSL::X509::Certificate.new
    csr_cert.serial = 0
    csr_cert.version = 2

    csr_cert.not_before = Time.now
    csr_cert.not_after = Time.now + (60*60*24*365)

    #get subject (name, locality, country etc from form)
    csr_cert.subject = parse_subject(params)
    
    csr_cert.public_key = csr.public_key
    csr_cert.issuer = @root_cert.subject


    @ef = OpenSSL::X509::ExtensionFactory.new
    @ef.subject_certificate = csr_cert
    @ef.issuer_certificate = @root_cert

    #checking what type of certificate needs to be created
    case params[:type]
      when 'Mail'
        puts params[:email]
        csr_cert.extensions = mail_extensions(params[:email])
      when 'Websites'
        csr_cert.extensions = dns_extensions(params[:dns])
      when 'Code signing'
        csr_cert.extensions = sign_extensions
    end

    #signing the certificate
    csr_cert.sign @root_key, OpenSSL::Digest::SHA1.new

    @uuid = SecureRandom.uuid
    puts @uuid.length

    #writing it to file
    #open "certificates/csr_cert.pem", 'w' do |io|
    #  io.write csr_cert.to_pem
    #end
    csr_cert

  end

  def mail_extensions email
        [ @ef.create_extension('basicConstraints', 'CA:FALSE'),
          @ef.create_extension('extendedKeyUsage', 'critical,emailProtection'),
          @ef.create_extension('subjectAltName', "email:#{email}"),
          @ef.create_extension('subjectKeyIdentifier', 'hash') ]
  end

  def dns_extensions dns
    [ @ef.create_extension('basicConstraints', 'critical, CA:FALSE'),
      @ef.create_extension('extendedKeyUsage', 'critical,serverAuth,clientAuth'),
      @ef.create_extension('subjectAltName', "DNS:#{dns}"),
      @ef.create_extension('subjectKeyIdentifier', 'hash') ]
  end

  def sign_extensions
    [ @ef.create_extension('basicConstraints', 'CA:FALSE'),
      @ef.create_extension('extendedKeyUsage', 'critical,codeSigning'),
      @ef.create_extension('subjectKeyIdentifier', 'hash') ]

  end

  def parse_subject params
    OpenSSL::X509::Name.parse "/CN=#{params[:common_name]}/DC=#{params[:dns]}/O=#{params[:organization]}/L=#{params[:locality]}/C=#{params[:country]}"
  end

end