I understand the concept; apply configuration based on features. But I have some points to discuss:

(1) there are configurations that I might want to override at the machine level. Let's say host ws-rafael, or its variant ws-rafael-vm overriding something that was defined in the shared host modules.

---

(2) my current implementation also permits me to do it at the user level, where I enable mangowm and dms by default, but disable them if the user is part of a WSL machine, like it is at work. These are things that I can do today with my all-in tags design. I do not know how I would do this kind of thing by moving to the dendritic pattern.

---

(3) something very peculiar about stylix is that I optionally add its home module when configuring the NixOS host. Take a look at tihs piece of code at hosts/shared/configuration.nix:

```nix
  ++ (forEach (attrValues hostcfg.userSettings) (
    usercfg: let
      inherit (usercfg) username;
      nixosSharedUserConfiguration = "${usercfg.path}/nixos/shared/user-configuration.nix";
      nixosHostUserConfiguration = "${usercfg.path}/nixos/hosts/${hostcfg.host}/user-configuration.nix";
      nixosUsercfg = mkMerge [
        {
         home = mkForce usercfg.homeDirectory;
          isNormalUser = mkDefault true;
        }
        ((import nixosSharedUserConfiguration) usercfg args)
        (mkIf (pathExists nixosHostUserConfiguration) ((import nixosHostUserConfiguration) usercfg args))
      ];
      userHomeModules = lib.local.project.getUserHomeModules usercfg;
      optionalUserHomeModules = [
        (mkIf (!config.home-manager.useGlobalPkgs) inputs.stylix.homeModules.stylix)
      ];
      homeUsercfg = mkMerge (userHomeModules ++ optionalUserHomeModules);
    in
      mkMerge [
        ...
      ]
    );
```

In my project evaluator code, I have getHostModules, getUserHomeModules, and getUserStandaloneHomeModules, the latter for the users who are configured by home-manager on non-NixOS machines. In fact, I just discovered that the host must use the user standalone home modules if config.home-manager.useGlobalPkgs == false.

---

How would I solve these points in the dendritic pattern?
