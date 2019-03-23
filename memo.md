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
