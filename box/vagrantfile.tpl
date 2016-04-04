require_relative "vagrant_plugin_guest_busybox.rb"
# require_relative "mount_virtualbox_shared_folder.rb"

Vagrant.configure("2") do |config|
  config.ssh.username = "docker"

  # Forward the Docker port
  config.vm.network :forwarded_port, guest: 2375, host: 2375, auto_correct: true

  # Disable synced folder by default
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  config.vm.provider: vmware_fusio do |v, override|
    v.vmx["bios.bootOrder"]    = "CDROM,hdd"
    v.vmx["ide1:0.present"]    = "TRUE"
    v.vmx["ide1:0.fileName"]   = File.expand_path("../docker-root.iso", __FILE__)
    v.vmx["ide1:0.deviceType"] = "cdrom-image"
  end
end
