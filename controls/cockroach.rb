# copyright: 2020, Spokey Wheeler

title "Basic Cockroach DB Check"

control 'cockroach-01' do
  impact 0.5
  title 'Cockroach directories and files'
  desc 'Check some key directories and files'
  describe file('/tmp') do
    it { should exist }
    its('type') { should cmp 'directory' }
    it { should be_sticky }
  end
  describe file('/usr/local/bin/cockroach') do
    it { should exist }
    it { should be_symlink }
    it { should be_linked_to '/opt/cockroach/cockroach-v19.2.2.linux-amd64/cockroach'}
    its('mode') { should cmp '0555' }
  end
  describe filesystem('/') do
    its('size_kb') { should be >= 10 * 1024 * 1024 }
    its('percent_free') { should be >= 30 }
  end
end

control 'cockroach-02' do
  impact 1.0
  title 'Cockroach should be running'
  desc 'check that it exists'
  describe processes('cockroach') do
    it { should exist } 
  end
end

control 'cockroach-03' do
  impact 0.7
  title 'Use latest stable Cockroach version'
  desc 'cockroach version should have build tag v19.2.2 and build type release'
  describe command("/usr/local/bin/cockroach version").stdout do
    it { should include 'v19.2.2' } 
    it { should include 'release' } 
  end
end

control 'cockroach-04' do
  impact 0.4
  title 'Only one instance of Cockroach should be running'
  desc 'ps -ef should only return one process'
  describe command("ps -ef | grep 'cockroach start' | grep -v grep | wc -l | awk '{print $1}'").stdout do
    it { should cmp 1 } 
  end
end

control 'cockroach-05' do
  impact 0.5
  title 'Check ports'
  desc 'cockroach should be listening to TCP on 26257 and serving the admin UI on 8080'

  describe port(26257) do
    it { should be_listening }
    its('processes') { should include 'cockroach' }
    its('protocols') { should cmp 'tcp' }
  end

  describe port(8080) do
    it { should be_listening }
    its('processes') { should include 'cockroach' }
    its('protocols') { should cmp 'tcp' }
  end
end

control 'cockroach-06' do
  impact 0.5
  title 'Check NTP'
  desc 'Check that NTP service is running'

  describe service('chronyd') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control 'cockroach-07' do
  impact 1.0
  title 'Check TLS'
  desc 'Check that the cluster is running with TLS'

  describe command("ps -ef | grep 'cockroach start' | grep '--insecure' | grep -v grep | wc -l | awk '{print $1}'").stdout do
    it { should cmp 0 }
  end
end

# number of CPUs between 2 and 32
# 2GB RAM per CPU
# filesystem is ext4
# volume size between 256GB and 512GB
# service times < 5ms
# free space > 20%
# file descriptors > 1956 but pref unlimited
# prometheus and node ports
# grafana port
# systemctl service running?
# curl http://localhost:8080/_status/vars
# curl http://localhost:8080/health
# curl http://localhost:8080/health?ready=1
#
