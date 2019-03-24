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

## p288
`initContainers` は `containers` と同じ階層に書く。
構造は双方同じ。`containers` は同時に起動するが、 `initContainers` は正常終了したら次へ、という形で、上から順番に起動される。
`chapter10/sample-initcontainer.yaml` 
`volumeMounts` の `name` を統一しないと初期化処理が `containers` に引き継がれない点は注意。

```sh
kubectl apply -f sample-initcontainer.yaml
# ファイルの書き込みを確認。
kubectl exec -it sample-initcontainer -- cat /usr/share/nginx/html/index.html
```

## p290
`containers` の `lifecycle` でも初期化処理などが可能。
```sh
kubectl apply -f sample-lifecycle.yaml
kubectl exec -it sample-lifecycle -- ls /tmp/started /tmp/poststart /tmp/prestop
```

この場合 `postStart` はエントリポイントと非同期に走るため、先に終了させたい初期化処理には `initContainers` を用いる。

## p292
Pod の安全な delete.
`preStop` に `sleep 1` などを指定すると、SIGTERMを受けて途中終了してしまうなどを防ぐことができる。
SIGTERM の2秒後SIGKILLでの強制終了が発生は固定、 `terminationGracePeriod` は設定可能。

## p298
```sh
# Nodeをスケジューリング対象から除外
kubectl cordon {node-name}
# Nodeをスケジューリング対象に
kubectl uncordon {node-name}

# Node上のPodを退避
kubectl drain {node-name}
```

一度は停止されてしまうので、アプリケーションが一時停止しても良いことはあらかじめ調べておく必要がある。ライフサイクルを適切に管理しておけば良い。

## p306
高度で柔軟なスケジューリング

```sh
kubectl get node -o=jsonpath='{.items[*].metadata.labels}'
# → デフォルトで Node には大量のラベルが貼られていることがわかる。

kubectl apply -f sample-nodeselector.yaml
# label を貼って NodeSelectorの条件を満たすNodeを作成
kubectl label node {node-name} disktype=ssd
# → Pending が終了して Running に

kubectl apply -f sample-node-affinity.yaml
# マニフェストに書いた node-name に必要なラベルを貼る。
kubectl label node {node-name} disktype=hdd
# → Pending が終了して Running に
```

and, or や優先、必須、ラベルだけでなくリソースの大小の条件なども指定可能。

`podAffinity`: `Pod` 間の近さを指定。

## p341
Affinity や NodeSelector のスケジューリングのまとめ

コンテナのローカルで疎通確認などを行いたい場合は以下のようにする。
```sh
kubectl exec -it pod-name bash
apt-get updata
apt-get install curl
curl 127.0.0.1
```

課題8
```sh
# ログを見る
kubectl exec -it tick-app-95f8548c5-7k9vc -- cat /logs/tick.log
# fluentd の stdout を見る。
kubectl logs tick-app-95f8548c5-4s6z9 -c fluentd
```
