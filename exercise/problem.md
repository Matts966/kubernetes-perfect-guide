[ここ](https://gist.github.com/cstoku/97d8208667d0642b9c5a6d8352ff662e) から引用

# No. 1

以下の要件の `Pod` を作成してください。

- `Pod` の名前は `web`
- `nginx` イメージでタグは `stable` を使用する
- `containerPort` で `80` を公開する

# No. 2

No. 1のPodを各ノードで1台ずつ起動するようなManifestを作成し、適用してください。

# No. 3

No. 2で作成したものへ、外部(AbemaTowersなど)から接続できるようなServiceを作成してください。

# No. 4

毎分、日時を出力するコンテナ(Pod)を起動するManifestを作成し、適用してください。

- `毎分` となるcronの設定は `*/1 * * * *`
- 日付を出力するコマンドは `date` コマンド
- `alpine` イメージでタグは `latest` を使用
- 名前は `output-date`

# No. 5

以下の要件の `Pod` を作成してください。

- `Pod` の名前は `cache`
- `redis` イメージでタグは `5.0` を使用する
- `containerPort` で `6379` を公開する
- リソース要求をCPUは `10m`  、メモリは `8Mi` に設定
- リソースの上限をCPUは `100m` 、メモリは `32Mi` に設定

# No. 6

以下のManifestを適用すると、 `Deployment` は作成されるが、 `Service` からの疎通性は取れません。
Probeの設定を変更し、 `Service` からの疎通性が取れるように修正し、適用してください。

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        livenessProbe:
          exec:
            command:
            - "/bin/true"
        readinessProbe:
          httpGet:
            path: '/indexx.html'
            port: 80
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
  - port: 80
```

# No. 7

下記のConfigMapとSecretを作成し、適用してください。

## ConfigMap

- 名前は `exam-cm`
- 下記のデータを設定
  - `listen_port` というKeyに `8888` というValueを設定
  - `content_body` というKeyに以下のValueを設定

```plain
aaa
bbb
ccc
```

## Secret

- 名前は `exam-secret`
- 下記のデータを設定
  - `secret_token` というKeyに `jr5mU.4TsM8` というValueを設定
- `data` を使うこと(`stringData` を使用しないこと)

# No. 8

以下の要件の `Deployment` を作成してください。

- `Deployment` の名前は `tick-app`
- `log-volume` という名前で `emptyDir` のボリュームを作成
- 1つ目のコンテナ
  - `alpine` イメージでタグは `3.9` を使用する
  - `log-volume` を `/logs` にマウント
  - 以下の `command` と `args` を指定する

```yaml
command: ["sh", "-c"]
args:
- |
  touch /logs/tick.log
  while :; do
    date -Iseconds >> /logs/tick.log
    sleep 1
  done
```

- 2つ目のコンテナ
  - `fluent/fluentd` イメージでタグは `v1.4-1` を使用する
  - `log-volume` を `/logs` にマウント
  - 以下の `ConfigMap` 適用し、 `/fluentd/etc` にマウント

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /logs/tick.log
      tag tick
      <parse>
        @type none
      </parse>
    </source>
    <filter tick>
      @type record_transformer
      enable_ruby true
      <record>
        message ${require 'time'; Time.iso8601(record["message"].to_s).strftime("%Y年%m月%d日 %H時%M分%S秒")}
      </record>
    </filter>
    <match tick>
      @type stdout
    </match>
```