$LOAD_PATH << './lib'
require 'PkiUtils'
require 'sinatra/base'
require 'openssl'


root_cert = PkiUtils.load_key('root-ca.pem')
puts root_cert.inspect

root_key = OpenSSL::PKey::RSA.new File.read 'root-ca.key'

name = OpenSSL::X509::Name.parse 'CN=test/DC=example'


key = PkiUtils.generate_key

csr = OpenSSL::X509::Request.new
csr.version = 0
csr.subject = name
csr.public_key = key.public_key
csr.sign key, OpenSSL::Digest::SHA1.new

open 'csr.pem', 'w' do |io|
  io.write csr.to_pem
end


csr = OpenSSL::X509::Request.new File.read 'csr.pem'

raise 'CSR can not be verified' unless csr.verify csr.public_key

csr_cert = OpenSSL::X509::Certificate.new
csr_cert.serial = 0
csr_cert.version = 2
csr_cert.not_before = Time.now
csr_cert.not_after = Time.now + (60*60*24*365)

csr_cert.subject = csr.subject
csr_cert.public_key = csr.public_key
csr_cert.issuer = root_cert.subject

extension_factory = OpenSSL::X509::ExtensionFactory.new
extension_factory.subject_certificate = csr_cert
extension_factory.issuer_certificate = root_cert

extension_factory.create_extension 'basicConstraints', 'CA:FALSE'
extension_factory.create_extension 'keyUsage',
                                   'keyEncipherment,dataEncipherment,digitalSignature'
extension_factory.create_extension 'subjectKeyIdentifier', 'hash'

csr_cert.sign root_key, OpenSSL::Digest::SHA1.new

open 'csr_cert.pem', 'w' do |io|
  io.write csr_cert.to_pem
end