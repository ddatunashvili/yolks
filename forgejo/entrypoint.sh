#!/bin/bash
cd /home/container || exit 1

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP

printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mforgejo --version\n"
forgejo --version

# Same expansion as the parkervcp yolks, so eggs written for them behave the same.
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e "\033[1m\033[33mcontainer@pterodactyl~ \033[0m${MODIFIED_STARTUP}"

eval ${MODIFIED_STARTUP}
