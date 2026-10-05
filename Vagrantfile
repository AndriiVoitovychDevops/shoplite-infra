# -*- mode: ruby -*-
# vi: set ft=ruby :
PUBKEY_PATH = ENV.fetch("SHOPLITE_PUBKEY", File.join(Dir.home, ".ssh", "shoplite.pub"))
abort "SSH public key not found: #{PUBKEY_PATH}" unless File.exist?(PUBKEY_PATH)
PUBKEY = File.read(PUBKEY_PATH).strip

NODES = [
  { name: "api", box: "bento/ubuntu-24.04", ip: "192.168.56.30" },
  { name: "db",  box: "bento/rockylinux-9", ip: "192.168.56.31" },
]

Vagrant.configure("2") do |config|
  NODES.each do |node_info|
    config.vm.define node_info[:name] do |node|
      node.vm.box      = node_info[:box]
      node.vm.hostname = node_info[:name]
      node.vm.network "private_network", ip: node_info[:ip]

      node.vm.provider "virtualbox" do |vb|
        vb.name   = "shoplite-#{node_info[:name]}"
        vb.memory = 1024
        vb.cpus   = 1
      end

      # Bash: runs inside the VM; the key arrives as the PUBKEY env variable
      node.vm.provision "shell",
        path: "scripts/bootstrap-ssh-key.sh",
        env:  { "PUBKEY" => PUBKEY }
    end
  end
end