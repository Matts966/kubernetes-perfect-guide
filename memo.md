# Memo

だいたい本の通りだけどせっかくなのでメモ

## p5
`alpine` は `sh` が入っているので `scratch` よりはデバッグしやすい。

## p8
マルチステージビルドによってバイナリだけを持った軽量なイメージを作れる。 → 起動が速くなる。
SIZE 382MB → 10.8MB
めちゃくちゃサイズにこだわるDocker好きなエンジニアさんがいて理解できてなかったけど、気持ちがなんとなくわかった。

同じREPOSITORY、TAG名でビルドすると、前のやつは名無しになって上書きされる。

## p15
できることがめっちゃ書いてある。

## p21
.kube/config に設定ファイルを置いて `kubectl` する。GKEノードは用意してもらえた。

```sh
kubectl run myapp \
    --image=nginx:1.12 \
    --replicas 3 \
    --labels="app=myapp"

kubectl create service loadbalancer \
    --tcp 80:80 myapp

kubectl get service myapp
```

EXTERNAL-IP にアクセスすると `nginx` が起動している。

## p25
ローカルでやる場合 `minikube`, もあるが、 Docker for mac でやるのが簡単。
ネットに繋がる場合は Playground を使うと良い。

## p45
`cluster` = `master` + `node`

`curl` や `kubecrl` をつかって　`master` のAPIを叩き `resouce` を管理する。

以下のコマンドで `pod` や配置された `Node` を確認可能。
```sh
kubectl get pod --output wide
```

## p46
`resouce` の分類（100を超えるものがあるが分類すると5つで、よく使う種類は上3つ）

## p49
`Namespace` による仮想的な `cluster` の分離。

```sh
kubectl get pod
ubectl get pod --namespace default
kubectl get namespace
kubectl get pod --namespace kube-public
kubectl get pod --namespace kube-system
```

## p51
認証情報と `Cluster` `User` `Context`
設定ファイルに書く。デフォルトで `~/.kube/config` に置かれる。コマンドでも作成可能。 `kubectx` コマンドを使えば切り替えは容易。

補完機能
bash 3系は動かないという情報があった。
```sh
brew install bash-completion@2

# .bashrc などに
export BASH_COMPLETION_COMPAT_DIR=/usr/local/etc/bash_completion.d
[[ -r /usr/local/etc/profile.d/bash_completion.sh ]] && . /usr/local/etc/profile.d/bash_completion.sh

kubectl completion bash >/usr/local/etc/bash_completion.d/kubectl
```

zshなら
```
source <(kubectl completion zsh)
```

`kubectl apply` は `create` と異なり、すでにファイルがある場合などは更新できる。履歴も残るので良い。
`-f` でファイル指定が可能。

## p62
ラベルについて。システムが使う場合もあるしアプリケーションで使うこともできる。 `metadata.labels` で定義できる。



## p74
`docker exec` 的なの
```sh 
kubectl exec -it sample-pod /bin/sh
# 引数ありの場合 -- をつける
kubectl exec -it sample-pod -- /bin/ls -l /
# パイプなど特殊文字を使う場合は sh に文字列で渡す。
kubectl exec -it sample-pod -- /bin/sh -c "ls | grep root"
```
なんでもできてしまう上、IaS的には他の方法を取るべきなので、あまり使うべきでない。

`kubectl` のコマンドは多いが、使うべきでないものが多い。
プロセスが起動しない時など、デバッグでは `describe` `logs` をよく使う。

## p85
`Pod` とは？、デザインパターンは？など。

### `Workloads` リソース
`Pod` ： 平たくいうとコンテナ。複数コンテナを束ねるパターンがいくつかある。
`ReplicaSet` ： 数を死守したいときに使うリソース。
`Deployment` ： デプロイなどの際に使う。基本80％これを使う。
他にも `Workloads` リソースはたくさんある。

`chapter05` に諸々ファイルがある。

`kind: ReplicaSet` による冗長化。 `template:` 以下にもとの設定をインデントして写せば良い。 

```sh
# 試しに削除してみるとセルフヒーリングで復活する。
kubectl delete pod ~
# モニタリング
kubectl describe rs sample-rs
```

## p99
`ReplicaSet` でのラベルはシステムで用いるので、一致している必要がある。

スケールする場合、マニフェスト( `yml` )を更新するか、動的にAPIを叩く運用も行う可能性がある。

kubectl では以下
```sh
scale rs sample-rs --replicas 5
```

## p102
`Deployment` は `kind` だけ変えればymlの構造は `ReplicaSet` と同じ。

`kubectl get pod --watch` で見ながら、 `sample-deployment.yaml` に変更を加え、 `kubectl apply -f sample-deployment.yaml` でローリングアップデートし、過程を観察できる。

もとのファイルに戻して `kubectl apply -f sample-deployment.yaml` すると、新しい `ReplicaSet` は作られず、ロールバックされる。 `template` 以下のハッシュ値が変更されない限り以前の `ReplicaSet` が使われる。

`kubectl` コマンドでロールバックも可能だが、履歴が追いづらいのでマニフェストを更新するのが良い。

`spec.strategy` 属性などでアップデートの方法を指定可能。
デフォルトは25％ずつのローリングアップデート。

