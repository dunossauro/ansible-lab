Vagrant.configure("2") do |config|

  config.vm.define "ansible_main" do |main|

    main.vm.box = "archlinux/archlinux"
    main.vm.network "public_network", use_dhcp_assigned_default_route: true#, bridge: "wlp2s0"

    main.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.name = "ansible_main"
    end

  end

  config.vm.define "arch" do |arch|
    arch.vm.box = "archlinux/archlinux"
    arch.disksize.size = "30GB"
    arch.vm.network "public_network", use_dhcp_assigned_default_route: true#, bridge: "wlp2s0"

    arch.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    arch.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
      systemctl restart sshd
      pacman -Syu --noconfirm
    SHELL
  end

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/focal64"
    ubuntu.vm.network "public_network", use_dhcp_assigned_default_route: true#, bridge: "wlp2s0"

    ubuntu.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    ubuntu.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
      systemctl restart sshd
      apt-get update
      apt-get upgrade -y
    SHELL

  end

  config.vm.define "centos" do |centos|
    centos.vm.box = "centos/stream8"
    centos.vm.network "public_network", use_dhcp_assigned_default_route: true#, bridge: "wlp2s0"

    centos.vm.provider "virtualbox" do |vb|
       vb.memory = "1024"
    end

    centos.vm.provision "shell", inline: <<-SHELL
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config    
      systemctl restart sshd
      dnf update -y
    SHELL

   end
end
