#!/bin/bash

namespace=${1:-sonarr}
username=${2:-admin}
password=${3:-password}
transmission_ns=${4:-transmission}
transmission_port=${5:-9091}
domain_root=${6:-local}

transmission_ns=$(echo "$transmission_ns" | tr -d '\r')
transmission_data=$(jq -n --arg username "$username" \
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
    { "name": "addPaused", "value": false },
    { "name": "useSsl", "value": false },
    { "name": "tvCategory", "value": "" },
    { "name": "tvDirectory", "value": ""}
  ],
  implementation: "Transmission",
  configContract: "TransmissionSettings",
  downloadClientType: "Transmission"
}')

remotepath_data=$(jq -n --arg transmission_ns "$transmission_ns" \
'{
  "host": ("transmission." + $transmission_ns + ".svc.cluster.local"),
  "localPath": "/media/downloads/complete/",
  "remotePath": "/downloads/complete"
}')

# Get the name of the Sonarr pod
sonarr_pod=$(kubectl get pods -n $namespace -o jsonpath='{.items[0].metadata.name}')

# Get the API key from the Sonarr pod
api_key=$(kubectl exec -n $namespace "$sonarr_pod" -- \
  cat /config/config.xml | grep '<ApiKey>' | sed -E 's:.*<ApiKey>(.*)</ApiKey>.*:\1:')

kubectl create secret generic homepage-api-key-sonarr --from-literal=apiKey="$api_key" -n $namespace --dry-run=client -o yaml | kubectl apply -f -

# cURL request to add Transmission as a download client on Sonarr
curl -X POST "https://$namespace.$domain_root/api/v3/downloadclient" \
  -H "X-Api-Key: $api_key" \
  -H "Content-Type: application/json" \
  --data "$transmission_data" \
  --insecure

  curl -X POST "https://$namespace.$domain_root/api/v3/remotepathmapping" \
  -H "X-Api-Key: $api_key" \
  -H "Content-Type: application/json" \
  --data "$remotepath_data" \
  --insecure
