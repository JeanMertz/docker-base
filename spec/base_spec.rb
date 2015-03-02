require 'spec_helper'

Dir.glob(File.join(File.dirname(__dir__), 'bin/*')).each do |path|
  binary = File.basename(path)

  describe file("/usr/local/bin/#{binary}") do
    it { is_expected.to be_executable }
  end
end

describe file('/usr/local/bin/gosu') do
  it { is_expected.to be_executable }
end

describe file('/etc/apk/repositories') do
  its(:content) { is_expected.to include('dl-2.alpinelinux.org') }
  its(:content) { is_expected.to include('dl-3.alpinelinux.org') }
end
