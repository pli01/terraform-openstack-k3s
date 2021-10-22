#!/bin/bash
set -e
set -x

helm_url="https://github.com/cdr/code-server/archive/refs/heads/main.tar.gz"
helm_name="vscode"
helm_chart="ci/helm-chart"

# get code-server archive
[ -d "${helm_name}-main" ] && exit 1
mkdir ${helm_name}-main
curl -ksL $helm_url | tar -zxvf - --strip-components=1 -C ${helm_name}-main

#
( cd ${helm_name}-main

# configuration
ingress_hostname="${vscode_hostname:?vscode_hostname not set}"
hub_http_proxy="${hub_http_proxy:?hub_http_proxy not set}"
# Tips: helm --set need to escaped ',' => '\,'
hub_no_proxy="$(echo "$hub_no_proxy,localhost,127.0.0.1,.svc.cluster.local,.cluster.local" | sed -e 's/,/\\,/g')"

helm status "$helm_name" && exit 1

helm install \
  $helm_name $helm_chart \
  --set extraVars[0].name=HTTP_PROXY \
  --set extraVars[0].value="$hub_http_proxy" \
  --set extraVars[1].name=HTTPS_PROXY \
  --set extraVars[1].value="$hub_http_proxy" \
  --set extraVars[2].name=NO_PROXY \
  --set extraVars[2].value="$hub_no_proxy" \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host="$ingress_hostname" \
  --set ingress.hosts[0].paths[0]="/"
)
