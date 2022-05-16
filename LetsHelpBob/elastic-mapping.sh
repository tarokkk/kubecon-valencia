#!/bin/bash
set -x

USERNAME=$(kubectl get secret one-eye-opensearch-user -o=jsonpath='{.data.username}'|base64 -D)
PASSWORD=$(kubectl get secret one-eye-opensearch-user -o=jsonpath='{.data.password}'|base64 -D)

kubectl port-forward svc/opensearch-cluster-master 9200:9200 &
PID=$!

#Wait for port-forward to open
sleep 5

curl -v -k -X PUT -H "Content-Type: application/json" -u $USERNAME:$PASSWORD https://localhost:9200/_index_template/nginx_template -d '{
  "index_patterns": [
    "nginx-*"
  ],
  "template": {
    "settings": {
      "number_of_shards": 1
    },
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "code": {
          "type": "integer"
        },
        "location_array": {
          "type": "geo_point"
        },
        "size": {
          "type": "integer"
        }
      }
    }
  }
}'

kill $PID