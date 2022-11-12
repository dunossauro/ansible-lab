Vagrant.configure("2") do |config|
  
  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
    arch.vm.network "public_network",
      use_dhcp_assigned_default_route: true

    arch.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    arch.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
      systemctl restart sshd
    SHELL
  end

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/focal64"
    ubuntu.vm.network "public_network",
      use_dhcp_assigned_default_route: true

    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    ubuntu.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
      systemctl restart sshd
    SHELL

  end

  config.vm.define "centos" do |centos|
    centos.vm.box = "centos/stream8"
    centos.vm.network "public_network",
      use_dhcp_assigned_default_route: true

    centos.vm.provider "virtualbox" do |vb|
       vb.memory = "1024"
    end

    centos.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
      systemctl restart sshd
    SHELL

   end
end
