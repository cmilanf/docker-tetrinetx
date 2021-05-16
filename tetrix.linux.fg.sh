#!/bin/sh
# https://serverfault.com/questions/608069/managing-daemons-with-supervisor-no-foreground-mode-available
set -eu
command=/opt/tetrinetx/bin/tetrix.linux

# Proxy signals
function kill_app() {
    kill $(pidof tetrix.linux)
    exit 0 # exit okay
}
trap "kill_app" SIGINT SIGTERM

# Launch daemon
$command
sleep 2

# Loop while the pidfile and the process exist
while kill -0 $(pidof tetrix.linux) ; do
    sleep 0.5
done
exit 1000 # exit unexpected
