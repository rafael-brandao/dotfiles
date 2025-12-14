{
  runtimePlatform = "wsl";

  system = "x86_64-linux";

  tags = [
    "dtp"
    "dtp.internal"
    "github-access" # TODO: this should be configured by the user in user space
  ];

  users = [
    "rafael"
  ];
}
