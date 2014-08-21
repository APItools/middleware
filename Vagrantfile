# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = "ubuntu/precise64"

  config.vm.provision "shell", inline: <<-SCRIPT
    apt-add-repository ppa:brightbox/ruby-ng -y
    apt-get update -y
    apt-get -y install ruby2.1 ruby2.1-dev ruby-switch
    ruby-switch --set ruby2.1
    gem install bundler --no-rdoc --no-ri
  SCRIPT

  config.vm.provision "shell",
    path: 'https://gist.githubusercontent.com/mikz/411dbbc2aad5f147f87b/raw/189d89917ff44dff4e079307b38f8265e05dc07c/travis.rb',
    args: '/vagrant'
end
