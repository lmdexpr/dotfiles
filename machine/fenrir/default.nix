{ ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  imports = [
    ../../os/nixos-gui
    ./hardware-configuration.nix
  ];

  services.thinkfan = {
    enable = true;

    sensors = [
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp6_input"; }
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp3_input"; }
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp7_input"; }
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp4_input"; }
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp8_input"; }
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp1_input"; }
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp5_input"; }
      { type = "hwmon"; query = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon5/temp2_input"; }
      { type = "hwmon"; query = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon2/temp1_input"; }
      { type = "hwmon"; query = "/sys/devices/pci0000:00/0000:00:02.1/0000:01:00.0/nvme/nvme0/hwmon0/temp1_input"; }
      { type = "hwmon"; query = "/sys/devices/pci0000:00/0000:00:02.1/0000:01:00.0/nvme/nvme0/hwmon0/temp2_input"; }
      { type = "hwmon"; query = "/sys/devices/pci0000:00/0000:00:08.1/0000:07:00.0/hwmon/hwmon7/temp1_input"; }
      { type = "hwmon"; query = "/sys/devices/pci0000:00/0000:00:02.6/0000:06:00.0/ieee80211/phy0/hwmon6/temp1_input"; }
      { type = "hwmon"; query = "/sys/devices/virtual/thermal/thermal_zone0/hwmon4/temp1_input"; }
    ];
  };

  networking.hostName = "fenrir";
}
