#!/bin/bash

helm_repo="https://charts.bitnami.com/bitnami"
helm_name="jupyter"
helm_chart="jupyterhub"

# configuration
ingress_hostname="${jupyter_hostname:?jupyter_hostname not set}"
hub_password="${jupyter_password:?jupyter_password not set}"
hub_http_proxy="${hub_http_proxy:?hub_http_proxy not set}"
# Tips: helm --set need to escaped ',' => '\,'
hub_no_proxy="$(echo "$hub_no_proxy,localhost,127.0.0.1,.svc.cluster.local,.cluster.local" | sed -e 's/,/\\,/g')"

helm status "$helm_name" && exit 1

kubectl delete pvc data-jupyter-postgresql-0 || true

#  --debug --dry-run
helm install \
  $helm_name $helm_chart \
  --repo $helm_repo \
  --set proxy.service.public.type=ClusterIP \
  --set proxy.ingress.enabled=true \
  --set proxy.ingress.hostname="$ingress_hostname" \
  --set hub.password="$hub_password" \
  --set hub.extraEnvVars[0].name=HTTP_PROXY \
  --set hub.extraEnvVars[0].value="$hub_http_proxy" \
  --set hub.extraEnvVars[1].name=HTTPS_PROXY \
  --set hub.extraEnvVars[1].value="$hub_http_proxy" \
  --set hub.extraEnvVars[2].name=NO_PROXY \
  --set hub.extraEnvVars[2].value="$hub_no_proxy"
