#!/bin/bash
# generated terraform template file
# place here all variables
cat <<'EOF' >/home/debian/app.cfg
%{ if dockerhub_login != "" ~}
export dockerhub_login="${dockerhub_login}"
%{ endif ~}
%{ if dockerhub_token != "" ~}
export dockerhub_token="${dockerhub_token}"
%{ endif ~}
%{ if github_token != "" ~}
export github_token="${github_token}"
%{ endif ~}
%{ if docker_registry_username != "" ~}
export docker_registry_username="${docker_registry_username}"
%{ endif ~}
%{ if docker_registry_token != "" ~}
export docker_registry_token="${docker_registry_token}"
%{ endif ~}
%{ if app_install_script != "" ~}
export app_install_script="${app_install_script}"
%{ endif ~}
%{for k,v in app_variables~}
%{ if v != "" ~}
export ${k}="${v}"
%{ else ~}
export ${k}=""
%{ endif ~}
%{endfor~}
#
EOF
