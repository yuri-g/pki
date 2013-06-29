$LOAD_PATH << './lib'
require 'PkiUtils'
require 'CertificateService'
require 'openssl'

class AuthorityApp < Sinatra::Base

  set :environment, 'production'

  get '/' do
    haml :index
  end

  post '/generate' do


    root_cert = PkiUtils.load_cert('root-ca.pem')
    root_key = PkiUtils.load_key('root-ca.key')

    puts params.inspect

    csr = PkiUtils.get_csr(params[:keygen])

    cservice = CertificateService.new(root_cert, root_key)
    
    csr_cert = cservice.generate(params, csr)
    csr_cert.to_pem
    haml :certificate, :locals => {:certificate => csr_cert.to_pem}
  end

end

