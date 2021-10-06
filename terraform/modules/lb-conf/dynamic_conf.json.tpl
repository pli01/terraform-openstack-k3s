"http": {
    "routers": {
        "whoami": {
            "entryPoints": [
                "web"
            ],
%{ if traefik_rule_host != "" ~}
            "rule": "Host(`${traefik_rule_host}`)",
%{ endif ~}
            "service": "whoami"
        }
    },
    "services": {
        "whoami": {
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
