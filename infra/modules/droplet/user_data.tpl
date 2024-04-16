#!/bin/bash

set -x
set -e

export DEBIAN_FRONTEND=noninteractive

echo "${SSH_KEYS}" >>/root/.ssh/authorized_keys
sed -i '/PasswordAuthentication yes/c\PasswordAuthentication no' /etc/ssh/sshd_config

# trick for digital ocean to not prompt you for the password change.
sed -i 's/^root:.*$/root:*:16231:0:99999:7:::/' /etc/shadow
service ssh restart
apt-get update
apt-get -yq install \
    wget \
    python3 \
    python3-pip \
    python3-jinja2 \
    python3-boto3 \
    python3-yaml \
    ca-certificates \
    curl \
    gnupg

pip3 install importlib-resources
pip3 install ansible-core
pip3 install ansible==4.10.0

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -yq install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# install nginx
apt -yq install nginx
snap install --classic certbot

# install github-runner
useradd --comment 'GitHub Runner' --create-home github-runner --shell /bin/bash
su - github-runner <<'EOF'
su github-runner
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.315.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.315.0/actions-runner-linux-x64-2.315.0.tar.gz
echo "6362646b67613c6981db76f4d25e68e463a9af2cc8d16e31bfeabe39153606a0  actions-runner-linux-x64-2.315.0.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-2.315.0.tar.gz
./config.sh --url ${GITHUB_RUNNER_URL} --token ${GITHUB_RUNNER_TOKEN} 
nohup ./run.sh &
EOF
${VOLUMES_COMANDS}
