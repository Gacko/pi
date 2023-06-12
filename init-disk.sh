#!/usr/bin/env zsh
# Get image, user configuration & disk.
image="${1}"
userconf="${2}"
disk="${3}"

# Check image & user configuration.
if [ ! -f "${image}" ] || [ ! -f "${userconf}" ]
then
  # Print usage.
  echo "Usage: ${0} image userconf [disk]"
  # Exit erroneous.
  exit 1
fi

# Check disk.
if [ -z "${disk}" ]
then
  # Get disk.
  disk="$(diskutil list internal physical | grep --only-matching "/dev/disk[1-9]" | head --lines 1)"

  # Confirm disk.
  diskutil list "${disk}" ; echo -n "Enter to dump image to this disk..." ; read
fi

# Check disk.
if [ ! -b "${disk}" ]
then
  # Print error.
  echo "Disk '${disk}' is not a block device."
  # Exit erroneous.
  exit 1
fi

# Get rdisk.
rdisk="${disk/disk/rdisk}"

# Check rdisk.
if [ ! -c "${rdisk}" ]
then
  # Print error.
  echo "Disk '${rdisk}' is not a character device."
  # Exit erroneous.
  exit 1
fi

# Unmount volumes.
diskutil unmountDisk "${disk}"

# Dump image.
sudo dd if="${image}" of="${rdisk}" bs=1m

# Await bootfs.
until [ -d /Volumes/bootfs ] ; do sleep 1 ; done

# Remove hidden directories.
rm -rf /Volumes/bootfs/.Spotlight-V100 /Volumes/bootfs/.fseventsd 

# Enable SSH.
touch /Volumes/bootfs/ssh

# Copy user configuration.
cp "${userconf}" /Volumes/bootfs/userconf.txt

# Eject disk.
diskutil eject "${disk}"
