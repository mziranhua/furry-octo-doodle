Vagrant.configure("2") do |config|
  #config.vm.box = "bento/ubuntu-16.04"
  config.vm.box = "bento/centos-7"
  config.vm.hostname = "debmirror01"
  config.vm.network "forwarded_port", guest: 80, host: 8084, host_ip: "127.0.0.1"
  ####### Install Puppet Agent #######
  config.vm.provision "shell", path: "./bootstrap.sh"
  ####### Provision #######
  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "./site"
    puppet.options = "--verbose --debug"
  end
end
