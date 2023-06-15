#!/usr/bin/env zsh
# Get host & private key.
host="${1}"
key="${2}"

# Check host & private key.
if [ -z "${host}" ] || [ -z "${key}" ]
then
  # Print usage.
  echo "Usage: ${0} host key"
  # Exit erroneous.
  exit 1
fi

# Copy public key.
ssh-keygen -f "${key}" -y | ssh "${host}" "mkdir -m 700 .ssh ; cat > .ssh/authorized_keys ; chmod 600 .ssh/authorized_keys"
