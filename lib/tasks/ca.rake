require 'openssl'

namespace :ca do
  desc 'Generates new root and intermediate certificates'
  task generate: :environment do
    Dir.mkdir Rails.root.join('private') unless File.exists? Rails.root.join('private')
    root_key_path = Rails.root.join('private', 'root_ca_key.pem')
    root_cert_path = Rails.root.join('private', 'root_ca.pem')
    intermediate_key_path = Rails.root.join('private', 'intermediate_ca_key.pem')
    intermediate_cert_path = Rails.root.join('private', 'intermediate_ca.pem')

    puts "Generating a new 8192-bit key for the root CA..."
    root_key = OpenSSL::PKey::RSA.new 8192
    open root_key_path, 'w', 0400 do |io|
      io.write root_key.export
    end

    root_name = OpenSSL::X509::Name.parse 'CN=Easyauth Root Authority'
    root_cert = OpenSSL::X509::Certificate.new
    root_cert.serial = 0
    root_cert.version = 2
    root_cert.not_before = Time.now
    root_cert.not_after = 10.years.from_now
    root_cert.public_key = root_key.public_key
    root_cert.subject = root_name
    root_cert.issuer = root_name
    root_extension_factory = OpenSSL::X509::ExtensionFactory.new
    root_extension_factory.subject_certificate = root_cert
    root_extension_factory.issuer_certificate = root_cert
    root_cert.add_extension root_extension_factory.create_extension('subjectKeyIdentifier', 'hash')
    root_cert.add_extension root_extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
    root_cert.add_extension root_extension_factory.create_extension('keyUsage', 'cRLSign,keyCertSign', true)
    root_cert.sign root_key, OpenSSL::Digest::SHA512.new
    open root_cert_path, 'w' do |io|
      io.write root_cert.to_pem
    end

    puts "Generating a new 8192-bit key for the intermediate CA..."
    intermediate_key = OpenSSL::PKey::RSA.new 8192
    open intermediate_key_path, 'w', 0400 do |io|
      io.write intermediate_key.export
    end

    intermediate_name = OpenSSL::X509::Name.parse 'CN=Easyauth Intermediate Authority'
    intermediate_csr = OpenSSL::X509::Request.new
    intermediate_csr.version = 0
    intermediate_csr.subject = intermediate_name
    intermediate_csr.public_key = intermediate_key
    intermediate_csr.sign intermediate_key, OpenSSL::Digest::SHA512.new
    intermediate_cert = OpenSSL::X509::Certificate.new
    intermediate_cert.serial = 0
    intermediate_cert.version = 2
    intermediate_cert.not_before = Time.now
    intermediate_cert.not_after = 10.years.from_now
    intermediate_cert.subject = intermediate_csr.subject
    intermediate_cert.public_key = intermediate_csr.public_key
    intermediate_cert.issuer = root_cert.subject
    intermediate_extension_factory = OpenSSL::X509::ExtensionFactory.new
    intermediate_extension_factory.subject_certificate = intermediate_cert
    intermediate_extension_factory.issuer_certificate = root_cert
    intermediate_cert.add_extension intermediate_extension_factory.create_extension('subjectKeyIdentifier', 'hash')
    intermediate_cert.add_extension intermediate_extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)
    intermediate_cert.add_extension intermediate_extension_factory.create_extension('keyUsage', 'cRLSign,keyCertSign', true)
    intermediate_cert.sign root_key, OpenSSL::Digest::SHA512.new
    open intermediate_cert_path, 'w' do |io|
      io.write intermediate_cert.to_pem
    end

    puts 'Your CAs have been created!'
    puts "Root CA key: #{root_key_path}"
    puts "Root CA certificate: #{root_cert_path}"
    puts "Intermediate CA key: #{intermediate_key_path}"
    puts "Intermediate CA certificate: #{intermediate_cert_path}"
    puts 'Make sure to store these safely. Move the root key to another ' \
         'machine if possible, and encrypt the intermediate with a ' \
         'passphrase.'
  end
end
