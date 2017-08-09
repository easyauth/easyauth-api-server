require 'singleton'

# Methods for issuing certificates
class CA
  include Singleton

  def initialize
    passphrase = Settings.ca.key_password unless Settings.ca.key_password.nil?
    key_pem = File.read Settings.ca.key_file
    @ca_key = OpenSSL::PKey::RSA.new key_pem, passphrase
    @ca_cert = OpenSSL::X509::Certificate.new File.read Settings.ca.cert_file
    @store = Dir.new Settings.ca.store_dir
  end

  def sign_csr(csr, user)
    raise 'CSR can not be verified' unless csr.verify csr.public_key

    serial = inc_serial
    csr_name = OpenSSL::X509::Name.parse "CN=Easyauth User ID #{user.id}/O=#{user.name}/OU=Easyauth Client Certificates"

    csr_cert = OpenSSL::X509::Certificate.new
    csr_cert.serial = serial
    csr_cert.version = 2
    csr_cert.not_before = Time.now
    csr_cert.not_after = 1.year.from_now
    csr_cert.subject = csr_name
    csr_cert.issuer = @ca_cert.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = csr_cert
    extension_factory.issuer_certificate = @ca_cert

    csr_cert.add_extension extension_factory.create_extension('basicConstraints', 'CA:FALSE')
    csr_cert.add_extension extension_factory.create_extension('keyUsage', 'digitalSignature')
    csr_cert.add_extension extension_factory.create_extension('subjectKeyIdentifier', 'hash')

    csr_cert.sign @ca_key, OpenSSL::Digest::SHA512.new

    cert_path = File.join(@store, "#{serial}.pem")
    open cert_path, 'w' do |file|
      file.write csr_cert.to_pem
    end

    Certificate.new(
      serial: serial,
      active: true,
      path: cert_path,
      user: user,
      valid_until: csr_cert.not_after
      )
  end

  private

  def inc_serial
    require 'securerandom'
    serial = if File.exist? Settings.ca.serial_file
               File.read(Settings.ca.serial_file).to_i
             else
               0
             end
    serial += Random.rand(3..12)
    File.open(Settings.ca.serial_file, 'w') { |file| file.write(serial.to_s) }
    serial
  end
end
