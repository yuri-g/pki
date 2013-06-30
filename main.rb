$LOAD_PATH << './lib'
require 'PkiUtils'
require 'CertificateService'
require 'openssl'
require 'SecureRandom'
require 'FileUtils'

class AuthorityApp < Sinatra::Base

  set :environment, 'production'

  get '/' do
    haml :index
  end

  post '/generate' do


    root_cert = PkiUtils.load_cert('root-ca.pem')
    root_key = PkiUtils.load_key('root-ca.key')

    puts params.inspect
    puts settings.db.class

    csr = PkiUtils.get_csr(params[:keygen])

    cservice = CertificateService.new(root_cert, root_key)

    uuid = SecureRandom.uuid
    csr_cert = cservice.generate(params, csr)
    settings.db.execute("INSERT INTO certificates (UUID, BODY) values (?, ?)", [uuid, csr_cert.to_pem])
    haml :generate, :locals => {:certificate => csr_cert.to_pem, :uuid => uuid}
  end

  get '/certificates/:uuid' do
    cert = settings.db.execute("SELECT BODY FROM certificates WHERE UUID = ?", [params[:uuid]])[0][0]
    haml :certificate, :locals => {:certificate => cert, :uuid => params[:uuid]}

  end

  get '/certificates/:uuid/download' do
    cert = settings.db.execute("SELECT BODY FROM certificates WHERE UUID = ?", [params[:uuid]])[0][0]
    cert_file = OpenSSL::X509::Certificate.new(cert)
    FileUtils.mkdir("./certificates/#{params[:uuid]}")
    open "./certificates/#{params[:uuid]}/cert.pem", 'w' do |io|
      io.write cert_file.to_pem
    end
    send_file "./certificates/#{params[:uuid]}/cert.pem", :filename => "csr_cert.pem", :type => 'Application/octet-stream'
  end

end

