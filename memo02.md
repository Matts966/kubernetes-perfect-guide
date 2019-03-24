## p126
```sh
# chapter05
kubectl apply -f sample-job.yaml
kubectl get pod --show-all
```
でJOBの終了などを確認。

## p135
cronjobs が job を生成している。
改めて階層関係は p85 を参照。
```
kubectl apply -f sample-cronjob.yaml
kubectl get cronjob
# 時間になるまで JOB は生成されない。
kubectl get job
```

`suspend` 属性で一旦止めておくことができる。

## p140
コンテナの主な起動方法である Workloads リソースのまとめ
図解は p85.

## p156
ネットワーク周りを改めて
Service は type を省略するとデフォルトで `ClusterIP` となる。

`Service` には他にも `Ingress` というL7（HTTP）レイヤのロードバランサーもある（LBはL4）。
`Ingress` の実装はプロバイダによって結構異なる。
パスによって流す先を変えるなども可能。

## p186
内側のLB `ClusterIP`, 外側のLBの中間にある `NodePort`

## p187
```sh
kubectl apply -f sample-ingress.yaml
kubectl apply -f sample-ingress-apps.yaml

# sample-ingress-apps-1/path1/index.html へのリクエストでホスト名を返す
kubectl exec -it sample-ingress-apps-1 -- mkdir /usr/share/nginx/html/path1/
kubectl exec -it sample-ingress-apps-1 -- cp /etc/hostname /usr/share/nginx/html/path1/index.html

# sample-ingress-apps-2/path2/index.html へのリクエストでホスト名を返す
kubectl exec -it sample-ingress-apps-2 -- mkdir /usr/share/nginx/html/path2
kubectl exec -it sample-ingress-apps-2 -- cp /etc/hostname /usr/share/nginx/html/path2/index.html

# sample-ingress-apps-3/index.html へのリクエストでホスト名を返す
kubectl exec -it sample-ingress-default -- cp /etc/hostname /usr/share/nginx/html/index.html

# 自己署名証明書の作成
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/tls.key -out ~/tls.crt -subj "/CN=sample.example.com"

# Secret の作成（証明書ファイルを指定した場合）
kubectl create secret tls --save-config tls-sample --key ~/tls.key --cert ~/tls.crt

# L7 ロードバランサの仮想IP を環境変数に保存
INGRESS_IP=`kubectl get ingresses sample-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`

# Ingress リソース経由のHTTP リクエスト（/path1/* > sample-ingress-svc-1）
curl http://${INGRESS_IP}/path1/index.html -H "Host: sample.example.com"
sample-ingress-apps-1

# Ingress リソース経由のHTTP リクエスト（/path2/* > sample-ingress-svc-2）
curl http://${INGRESS_IP}/path2/index.html -H "Host: sample.example.com"
sample-ingress-apps-2

# Ingress リソース経由のHTTP リクエスト（/* > sample-ingress-default）
curl http://${INGRESS_IP}/index.html -H "Host: sample.example.com"
sample-ingress-default

# Ingress リソース経由のHTTPS リクエスト
curl https://${INGRESS_IP}/path1/index.html -H "Host: sample.example.com" --insecure
sample-ingress-apps-1
```

## p258
Resource の制限とオートスケーリング
`resources.requests`, ``resources.limits` を用いて、CPU, Memory の上限と下限を設定できる。差を広げると、割り当て後負荷が大きくなりすぎてしまう可能性があるので、2倍程度に抑える。

## p262
Cluster Autoscaler ： スケジューリングが厳しくなった時に `Node` を追加する仕組み。
こちらの機能も `resources.requests` をうまく設定することで、適切なタイミングでスケーリングすることができる。

`resources.requests` がないと異常な数の `Pod` が詰められてしまうので、設定がない場合はデフォルト値が適用される。

## p273
Horizontal Pod Autoscaler ： `Deployment` リソースの `replica` を自動でスケールさせるためのリソース。
`chapter09/sample-hpa.yaml`

Vertical Pod Autoscaler ： CPU のリソース割り当てによるスケーリング。

## p276 
リソース管理とオートスケーリングのまとめ

## p278
コンテナのヘルスチェック
Liveness Probe: 正常に動作しているか、していなければ再起動。
メモリリークで死んだ場合など
`chapter10/sample-liveness.yaml`

Readiness Probe: サービスイン可能か、可能でなければトラフィックは流さない。
接続が一時的に死んだ場合など
`chapter10/sample-readiness.yaml`

