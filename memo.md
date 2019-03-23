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

## p62
ラベルについて。システムが使う場合もあるしアプリケーションで使うこともできる。 `metadata.labels` で定義できる。



