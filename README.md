Create a service account and save the token

Install the log socket service
```bash
helm install log-socket Logging-with-RBAC/log-socket
```

```bash
kubectl create sa alice
export ALICE_TOKEN=$(kubectl get secret $(kubectl get sa alice -o=jsonpath='{.secrets[0].name}') -o=jsonpath='{.data.token}' | base64 -D)
```

```bash
kubectl create sa bob
export BOB_TOKEN=$(kubectl get secret $(kubectl get sa bob -o=jsonpath='{.secrets[0].name}') -o=jsonpath='{.data.token}' | base64 -D)
```

Add policy label to the Pod

```bash
helm upgrade foo LetsHelpBob/log-generator --set extraLabels.rbac/default_alice=allow
```

```bash
helm install bar LetsHelpBob/log-generator --set extraLabels.rbac/default_bob=allow --set extraLabels.rbac/default_alice=allow
```

Tail the flow

```bash
./k8stail flow default/geoip-flow --token $ALICE_TOKEN 2>/dev/null | jq 'if .kubernetes != null then .kubernetes.pod_name else .error end'
```

```bash
./k8stail flow default/geoip-flow --token $BOB_TOKEN 2>/dev/null | jq 'if .kubernetes != null then .kubernetes.pod_name else .error end'
```

```
kubectl get logging-all
kubectl get output geoip-flow-tailer -o yaml|yq
kubectl get flow geoip-flow -o yaml|yq

```

Get all object that I can grab log from

```bash
kubectl get po -l rbac/default_alice=allow -A 
```

```bash
helm upgrade bar LetsHelpBob/log-generator --set extraLabels.rbac/default_bob=allow --set extraLabels.rbac/default_alice=deny
```