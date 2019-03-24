## p126
```sh
# chapter05
kubectl apply -f sample-job.yaml
kubectl get pod --show-all
```
でJOBの終了などを確認。

## p135
cronjobs が job を生成している。
```
kubectl apply -f sample-cronjob.yaml
kubectl get cronjob
# 時間になるまで JOB は生成されない。
kubectl get job
```

`suspend` 属性で一旦止めておくことができる。
