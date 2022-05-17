kubectl delete -f LetsHelpBob/s3-logs
kubectl delete -f LetsHelpBob/access-log-configs/output-access-log-os.yaml
kubectl delete -f LetsHelpBob/access-log-configs/flow-acces-log-geoip.yaml
kubectl delete -f LetsHelpBob/access-log-configs/null-output.yaml
helm delete bar
helm delete foo
