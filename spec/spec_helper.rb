require 'serverspec'
require 'excon'
require 'docker'

set :backend, :docker

Excon.defaults[:ssl_verify_peer] = false

Docker.options = { read_timeout: 600, write_timeout: 600 }

RSpec.configure do |config|
  config.before(:suite) do
    puts 'preparing new Docker image for testing...'

    files = Dir.glob('*').reject { |f| f.include?('vendor') }
    tmp   = Tempfile.new(SecureRandom.urlsafe_base64)

    Archive::Tar::Minitar.pack(files, tmp, true)
    tar = File.new(tmp.path, 'r')

    image = Docker::Image.build_from_tar(tar, t: 'blendle/base:test')
    config.docker_image = image.id
  end

  config.docker_container_create_options = {
    'Cmd' => ['/usr/bin/tail', '-f', '/dev/null'] # keep-alive
  }
end

Docker.options = { read_timeout: 60, write_timeout: 60 }
