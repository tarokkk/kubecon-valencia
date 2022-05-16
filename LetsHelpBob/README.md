Kubecon Valencia - Let's Help Bob!

This is a quickstart to get familiar with the logging oeprator. We will start with basics and extend the configuration in small steps.

## Environment

To speed up things I already deployed a couple of things on the cluster:
- Logging Operator
- Prometheus Operator
- Opensearch
- MCOM UI (for visualization)

### 1. First let's generate some log

Log generator is a simple tool that generates randomized nginx log access log format.

```bash
helm install foo log-generator
```

And chek what kind of output we have
```bash
kubectl logs -f -l app.kubernetes.io/name=log-generator
```

### 2. AWS S3 Archive

- First we need to create our secret to access the S3 bucket.

```bash
kubectl apply -f s3-logs/s3-secret.yaml
```

- Now we can configure the S3 output

```bash
cat s3-logs/clusteroutput-default-s3.yaml | yq
kubectl apply -f s3-logs/clusteroutput-default-s3.yaml
```

- And finally apply the ClusterFlow

```bash
cat s3-logs/clusterflow-s3-all-log.yaml | yq
kubectl apply -f s3-logs/clusterflow-s3-all-log.yaml
```

We can check the result with kubectl or MCOM UI
[http://localhost:8080/logging-overview](http://localhost:8080/logging-overview)
```bash
kubectl get logging-all
```

### 3. Export logs to metrics

Let's move on and work on those access logs.

- As for this example we don't realy need a log destination we create a null output.

```bash
cat access-log-configs/null-output.yaml | yq
kubectl apply -f access-log-configs/null-output.yaml
```

- Now we have a destination we can create the Flow. First we need a label to select for.

```bash
kubectl get po -l app.kubernetes.io/name=log-generator
```

```bash
cat access-log-configs/1-simple-selector.yaml | yq
kubectl apply -f access-log-configs/1-simple-selector.yaml
```

- Let's move on and add a parser.

```bash
cat access-log-configs/2-parse-nginx.yaml | yq
kubectl apply -f access-log-configs/2-parse-nginx.yaml
```

- Apply the prometheus filter
```bash
cat access-log-configs/3-add-prometheus-metrics.yaml | yq
kubectl apply -f access-log-configs/3-add-prometheus-metrics.yaml
```

- We can apply a rule to alert for failure
```bash
cat access-code-alert.yaml |yq
kubectl apply -f access-code-alert.yaml
```

Check the result on Prometheus
[http://localhost:8080/prometheus/graph](http://localhost:8080/prometheus/graph)

-  Do the GeoIP magic
```bash
bash elastic-mapping.sh
```


First ensure that OpenSearch mapping is in place

```bash
cat access-log-configs/output-access-log-os.yaml | yq
kubectl apply -f access-log-configs/output-access-log-os.yaml
cat access-log-configs/4-add-geoip-and-es.yaml | yq
kubectl apply -f access-log-configs/4-add-geoip-and-es.yaml
```

- Check the Opensearch dashboard
```bash
kubectl port-forward svc/opensearch-dashboards 5601:5601
```

```bash
kubectl get secret one-eye-opensearch-user -o=jsonpath='{.data.password}'|base64 -D | pbcopy
```