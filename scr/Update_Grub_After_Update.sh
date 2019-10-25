#!/bin/bash

# Check privileges
if [[ $(/usr/bin/id -u) -ne 0 ]] ; then
    echo "Not running as root"
    exit 1
fi

# Display current settings
echo -e " Old settings:"
efibootmgr -v

# Update the files
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Boot || exit 2

# Copy the files
mv /boot/EFI/Boot/grubx64.efi /boot/EFI/Boot/Bootx64.efi || exit 3

# Remove previous duplicate entries
ENTRIES="$(efibootmgr -v | grep -i '\\efi\\boot\\bootx64.efi' | awk '{print $1}' | sed -E 's/Boot([0-9A-Fa-f]{4}).*/\1/g')"
ENTRIES+="$(efibootmgr -v | grep -i '\\efi\\boot\\grubx64.efi' | awk '{print $1}' | sed -E 's/Boot([0-9A-Fa-f]{4}).*/\1/g')"

for var in ${ENTRIES} ; do
    echo " Removing entry: (${var})"
    efibootmgr -b "${var}" -B -q
done

# Add efi entry
efibootmgr -c -g -d /dev/sda -p 1 -w -L "Windows Boot Manager" -l '\EFI\Boot\Bootx64.efi' -q || exit 4

# Update config
grub-mkconfig -o /boot/grub/grub.cfg

# Print the new information
echo -e " New information is:"
efibootmgr -v

exit 0
