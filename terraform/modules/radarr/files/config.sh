#!/bin/bash

namespace=${1:-radarr}
username=${2:-admin}
password=${3:-password}
transmission_ns=${4:-transmission}
transmission_port=${5:-9091}
domain_root=${6:-local}

transmission_ns=$(echo "$transmission_ns" | tr -d '\r')
json_data=$(jq -n --arg username "$username" \
                  --arg password "$password" \
                  --arg transmission_ns "$transmission_ns" \
                  --arg transmission_port "$transmission_port" \
'{
  enable: true,
  protocol: "torrent",
  priority: 1,
  removeCompletedDownloads: true,
  removeFailedDownloads: true,
  name: "Transmission",
  fields: [
    { "name": "host", "value": ("transmission." + $transmission_ns + ".svc.cluster.local") },
    { "name": "port", "value": $transmission_port },
    { "name": "username", "value": $username },
    { "name": "password", "value": $password },
    { "name": "category", "value": "radarr" },
    { "name": "recentTvPriority", "value": 1 },
    { "name": "olderTvPriority", "value": 1 },
    { "name": "addPaused", "value": false },
    { "name": "useSsl", "value": false },
    { "name": "tvCategory", "value": "radarr" }
  ],
  implementation: "Transmission",
  configContract: "TransmissionSettings",
  downloadClientType: "Transmission"
}')

# Get the name of the Radarr pod
radarr_pod=$(kubectl get pods -n $namespace -o jsonpath='{.items[0].metadata.name}')

# Get the API key from the Radarr pod
api_key=$(kubectl exec -n $namespace "$radarr_pod" -- \
  cat /config/config.xml | grep '<ApiKey>' | sed -E 's:.*<ApiKey>(.*)</ApiKey>.*:\1:')

# cURL request to add Transmission as a download client on Radarr
curl -X POST "https://$namespace.$domain_root/api/v3/downloadclient" \
  -H "X-Api-Key: $api_key" \
  -H "Content-Type: application/json" \
  --data "$json_data" \
  --insecure