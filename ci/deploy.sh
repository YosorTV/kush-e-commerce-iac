#!/bin/bash

set -e
set -u

scriptpath="$(readlink -f "$0")"
workdir="${scriptpath%/*}"
cd "${workdir}/../../ansible"

echo "${ANSIBLE_VAULT_PASSWORD}" > .password
ansible-playbook -e environment_name="${ENVIRONMENT_NAME}" -e frontend_port="${FRONTEND_PORT}" -e backend_port="${BACKEND_PORT}" -e app_sever=localhost -e app_domain="${APP_DOMAIN}" playbooks/nginx.yml
