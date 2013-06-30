$LOAD_PATH << './lib'
require 'PkiUtils'
require 'CertificateService'
require 'openssl'
#require 'SecureRandom'
#require 'FileUtils'

class AuthorityApp < Sinatra::Base

  set :environment, 'production'

  get '/' do
    haml :index
  end


  get '/root.crl' do
    send_file './crl/root.crl'
  end


  get '/root.crt' do
    send_file './root-ca/root-ca.pem', :filename => "root.crt"
  end

  post '/generate' do

    root_cert = PkiUtils.load_cert('./root-ca/root-ca.pem')
    root_key = PkiUtils.load_key('./root-ca/root-ca.key')
    root_crl = OpenSSL::X509::CRL.new
    root_crl.issuer = root_cert.subject
    root_crl.sign(root_key, OpenSSL::Digest::SHA1.new)
    open "root.crl", 'w' do |io|
      io.write(root_crl.to_der)
    end

    csr = PkiUtils.get_csr(params[:keygen])

    cservice = CertificateService.new(root_cert, root_key)

    uuid = SecureRandom.uuid
    serial = count_serial(settings.db)
    csr_cert = cservice.generate(params, csr, serial)
    store_certificate(uuid, csr_cert.to_pem)
    haml :generate, :locals => {:certificate => csr_cert.to_pem, :uuid => uuid}
  end




  get '/certificates/:uuid' do
    cert = retrieve_certificate(params[:uuid])
    haml :certificate, :locals => {:certificate => cert, :uuid => params[:uuid]}

  end


  get '/certificates/:uuid/download' do
    cert = retrieve_certificate(params[:uuid])
    cert_file = OpenSSL::X509::Certificate.new(cert)
    FileUtils.mkdir("./certificates/#{params[:uuid]}")
    open "./certificates/#{params[:uuid]}/cert.pem", 'w' do |io|
      io.write cert_file.to_pem
    end
    send_file "./certificates/#{params[:uuid]}/cert.pem", :filename => "csr_cert.crt", :type => 'Application/octet-stream'
  end

  def count_serial(db)
    db.execute("SELECT COUNT(*) FROM certificates")[0][0]
  end


  def retrieve_certificate uuid
    settings.db.execute("SELECT BODY FROM certificates WHERE UUID = ?", [uuid])[0][0]
  end

  def store_certificate(uuid, cert)
    settings.db.execute("INSERT INTO certificates (UUID, BODY) values (?, ?)", [uuid, cert])
  end

end

