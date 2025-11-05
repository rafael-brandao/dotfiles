printf "\ncopying guest clevis secrets to host ... \n" &&
scp -r "rafael@ws-rafael-vm:~/secrets/" "hosts/host/ws-rafael/variants/ws-rafael-vm/" &&
printf "done!\n\n" &&
printf "host cryptroot.jwe sha1sum : " &&
sha1sum "hosts/host/ws-rafael/variants/ws-rafael-vm/secrets/cryptroot.jwe" | awk '{print $1}' &&
printf "guest cryptroot.jwe sha1sum: " &&
ssh rafael@ws-rafael-vm "sha1sum ~/secrets/cryptroot.jwe | awk '{print \$1}'" &&
printf "\n" &&
printf "host cryptswap.jwe sha1sum : " &&
sha1sum "hosts/host/ws-rafael/variants/ws-rafael-vm/secrets/cryptswap.jwe" | awk '{print $1}' &&
printf "guest cryptswap.jwe sha1sum: " &&
ssh rafael@ws-rafael-vm "sha1sum ~/secrets/cryptswap.jwe | awk '{print \$1}'" &&
printf "\n" &&
printf "building ws-rafael-vm locally ...\n" &&
nix build '.#nixosConfigurations.ws-rafael-vm.config.system.build.toplevel' &&
printf "\ndone!" &&
printf "\n" &&
printf "deploying configuration to guest ws-rafael-vm ...\n" &&
nixos-rebuild switch \
--flake .#ws-rafael-vm \
--sudo \
--no-reexec \
--target-host rafael@ws-rafael-vm &&
printf "\ndone!" &&
printf "\n" &&
printf "rebooting guest ... " &&
ssh rafael@ws-rafael-vm 'sudo reboot' &&
echo "done!"
