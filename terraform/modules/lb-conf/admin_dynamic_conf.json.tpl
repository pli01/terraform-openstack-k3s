{
  "tcp": {
    "routers": {
      "k3s": {
        "entryPoints": [
          "websecure"
        ],
        "rule": "HostSNI(`*`)",
        "service": "k3s",
        "tls": {
          "passthrough": true
        }
      }
    },
    "services": {
      "k3s": {
        "loadBalancer":
%{ if traefik_loadbalancers_servers != "" ~}
${jsonencode({
             "servers": [
                for addr in traefik_loadbalancers_servers : { "address": "${addr}:6443" }
             ],
})}
%{ endif ~}
      }
    }
  },
  "http": {
    "middlewares": {
      "portainerHeader": {
        "headers": {
          "customRequestHeaders": {
            "Host": "portainer"
          }
        }
      }
    },
    "routers": {
        "portainer": {
            "entryPoints": [
                "web"
            ],
%{ if traefik_rule_host != "" ~}
            "rule": "Host(${traefik_rule_host})",
%{ else ~}
            "rule": "Path(`/`)",
%{ endif ~}
            "service": "portainer",
            "middlewares": [
               "portainerHeader"
            ]
        }
    },
    "services": {
        "portainer": {
            "loadbalancer":
%{ if traefik_loadbalancers_servers != "" ~}
${jsonencode({
             "servers": [
                for addr in traefik_loadbalancers_servers : { "url": "http://${addr}" }
             ],
})}
%{ endif ~}
        }
    }
  }
}
