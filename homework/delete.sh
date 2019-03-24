kubectl delete service wp-clusterip
kubectl delete service wp-lb
kubectl delete configmap --all
kubectl delete secret --all
kubectl delete statefulset wp-db-stateful
kubectl delete deployment --all
kubectl delete persistentvolume --all
kubectl delete persistentvolumeclaim --all
