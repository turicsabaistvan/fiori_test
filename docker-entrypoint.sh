#!/bin/bash
set -e

# The plugins are baked into the image at build time, so the runtime
# entrypoint only prepares the SSH key and hands over to Jenkins.
if [ -x /usr/local/bin/generate-ssh-key.sh ]; then
    /usr/local/bin/generate-ssh-key.sh
fi

exec /usr/local/bin/jenkins.sh "$@"
