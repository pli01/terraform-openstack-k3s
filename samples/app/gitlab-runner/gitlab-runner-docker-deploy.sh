#!/bin/bash

cat <<'EOF_RUNNER' > /home/debian/install_runner.sh
#!/bin/bash
echo "## runner configuration"
export no_proxy=$no_proxy
export http_proxy=$internal_http_proxy
export https_proxy=$internal_http_proxy
export gitlab_runner_version=${gitlab_runner_version:-latest}
export GITLAB_URL=$gitlab_url
export GITLAB_AUTH_TOKEN=$gitlab_auth_token
export DOCKER_AUTH_CONFIG="$docker_auth_config"
export GITLAB_RUNNER_TAG="docker,openstack,$gitlab_runner_tag"

[ -z "$GITLAB_URL" -a -z "$GITLAB_AUTH_TOKEN" ] && exit 1
echo "## installation des pre-requis"
apt-get -q update

# download
curl -LJO https://gitlab-runner-downloads.s3.amazonaws.com/${gitlab_runner_version}/deb/gitlab-runner_amd64.deb
[ -f "gitlab-runner_amd64.deb" ] || exit $?
dpkg -i "gitlab-runner_amd64.deb"

# proxy
mkdir /etc/systemd/system/gitlab-runner.service.d/
cat <<EOF > /etc/systemd/system/gitlab-runner.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${http_proxy}"
Environment="NO_PROXY=localhost,127.0.0.1,${no_proxy}"
EOF

sudo systemctl daemon-reload
sudo systemctl restart gitlab-runner

# get certificate

export GITLAB_HOST="$(basename $GITLAB_URL)"

# recuperation certificat autosigne forge
mkdir  -p /etc/gitlab-runner/certs/
( cd /etc/gitlab-runner/certs/ && echo | openssl s_client -servername $GITLAB_HOST -proxy $(basename $https_proxy) -connect $GITLAB_HOST:443  </dev/null 2>/dev/null | openssl x509 -text > $GITLAB_HOST.crt )
[ -s /etc/gitlab-runner/certs/$GITLAB_HOST.crt ] || exit 1

RUNNER_NAME=${RUNNER_NAME:-$(hostname -s)}
# register
gitlab-runner register \
  --non-interactive \
  --name "$RUNNER_NAME" \
  --url "$GITLAB_URL"   \
  --registration-token "$GITLAB_AUTH_TOKEN"   \
  --tag-list "$GITLAB_RUNNER_TAG" \
  --run-untagged="true" \
  --locked="true" \
  --clone-url="$GITLAB_URL" \
  --executor "docker" \
  --shell "bash" \
  --docker-image debian:stretch \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
  --pre-clone-script "git config --global http.proxy $http_proxy; git config --global https.proxy $http_proxy ; git config --global http.sslVerify \"false\";" \
  --env "DOCKER_AUTH_CONFIG=$DOCKER_AUTH_CONFIG" \
  --env "https_proxy=$https_proxy" \
  --env "http_proxy=$http_proxy" \
  --env "no_proxy=$no_proxy"   \
  --env "GIT_SSL_NO_VERIFY=true"

# cron cleanup
cat <<'EOF' > cleanup.crontab
PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
# every day at 5
0 5 * * * docker system prune --volumes -af 2>&- >/dev/null || echo "ERROR: docker system prune  $(hostname)"
15 5 * * * docker image prune -af 2>&- >/dev/null || echo "ERROR: docker image prune error $(hostname)"
EOF
crontab -u debian cleanup.crontab
EOF_RUNNER
chmod +x /home/debian/install_runner.sh
sudo -E /bin/bash -x /home/debian/install_runner.sh