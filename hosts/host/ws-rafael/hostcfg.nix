{
  runtimePlatform = "bare-metal";

  system = "x86_64-linux";

  tags = [
    "desktop"
    "dtp"
    "github-access" # TODO: this should be configured by the user in user space
    "virtual-machine"
    "workstation"
  ];

  users = [
    "rafael"
  ];
}
