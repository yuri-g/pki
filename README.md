#PKI
## Certificate issuing service implemented in Ruby.

###Prerequisites
* ruby, rubygems


###Usage
* Use [bundler](http://gembundler.com/) to install all the gems needed:
`bundle install`
* Run the application:
`rackup`



config


commands

### generate the CA key
openssl genrsa -out root-ca.key 4096