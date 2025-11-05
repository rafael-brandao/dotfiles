set -x CRYPTROOT_PASSWORD "teste_cryptroot" &&
set -x CRYPTSWAP_PASSWORD "teste_cryptswap" &&
echo "" &&
printf "encrypting cryptroot password into ~/secrets/cryptroot.jwe ... " &&
echo -n $CRYPTROOT_PASSWORD | clevis encrypt tang '{"url":"10.0.2.2:7654"}' -y > ~/secrets/cryptroot.jwe &&
echo "done!" &&
printf "decrypting ~/secrets/cryptroot.jwe: " &&
clevis decrypt < ~/secrets/cryptroot.jwe &&
echo "" &&
printf "~/secrets/cryptroot.jwe sha1sum   : " &&
sha1sum ~/secrets/cryptroot.jwe | awk '{print $1}' &&
echo "" &&
printf "encrypting cryptswap password into ~/secrets/cryptswap.jwe ... " &&
echo -n $CRYPTSWAP_PASSWORD | clevis encrypt tang '{"url":"10.0.2.2:7654"}' -y > ~/secrets/cryptswap.jwe &&
echo "done!" &&
printf "decrypting ~/secrets/cryptswap.jwe: " &&
clevis decrypt < ~/secrets/cryptswap.jwe &&
echo "" &&
printf "~/secrets/cryptswap.jwe sha1sum   : " &&
sha1sum ~/secrets/cryptswap.jwe | awk '{print $1}'
