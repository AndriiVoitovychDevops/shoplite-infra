# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	nodes = [
		{ name: "api", box: "bento/ubuntu-24.04",     ip: "192.168.56.30" },
		{ name: "db", box: "bento/rockylinux-9", ip: "192.168.56.31" }
	]
	
	nodes.each do |node_info|
		config.vm.define node_info[:name] do |node|
			node.vm.box      = node_info[:box]
			node.vm.hostname = node_info[:name]
			node.vm.network "private_network", ip: node_info[:ip]
			
			node.vm.provider "virtualbox" do |vb|
				vb.name   = "shoplite-#{node_info[:name]}"
				vb.memory = "2048"
				vb.cpus = 2
			end
			
			node.vm.provision "shell", inline: <<-SHELL
				path: "../scripts/bootstrap-ssh-key.sh",
  				env:  { "PUBKEY" => PUBKEY }
				
				mkdir -p /home/vagrant/.ssh
				touch /home/vagrant/.ssh/authorized_keys
				grep -qF "#{PUBKEY}" /home/vagrant/.ssh/authorized_keys || echo "#{PUBKEY}" >> /home/vagrant/.ssh/authorized_keys
				chown -R vagrant:vagrant /home/vagrant/.ssh
				chmod 700 /home/vagrant/.ssh
				chmod 600 /home/vagrant/.ssh/authorized_keys
				echo "ShopLite key installed on $(hostname)"
			SHELL
		end
	end
end