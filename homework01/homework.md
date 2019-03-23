[ここ](https://gist.github.com/cstoku/ba81be1908a3a199a04f00ec3edc1098)から引用。

以下のMulti-Containerで構成された `Pod` を次の要件に合わせた構成に変更してください。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: 127.0.0.1
        - name: WORDPRESS_DB_USER
          value: wordpress
        - name: WORDPRESS_DB_PASSWORD
          value: wordpress
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_DATABASE
          value: wordpress
        - name: MYSQL_USER
          value: wordpress
        - name: MYSQL_PASSWORD
          value: wordpress
        - name: MYSQL_RANDOM_ROOT_PASSWORD
          value: "yes"
```

- データベースの接続先 / DB名 / ユーザ名とrootユーザのパスワードをランダムにする設定を格納した `ConfigMap` を作成
- データベースのパスワードを格納した `Secret` を作成
- wordpress用の `Service` を作成
  - typeは `Loadbalancer` を指定する
- wordpressの `Deployment`を作成
  - 適宜 `ConfigMap` と `Secret` を環境変数に設定すること
- mysql用の `Service` を作成
  - typeは `ClusterIP` を指定する
- mysqlの `StatefulSet` を作成
  - 適宜 `ConfigMap` と `Secret` を環境変数に設定すること
  - `PersistentVolumeClaim` の容量に `10Gi` を指定し、 `/var/lib/mysql` にマウント
  - `initContainer` で `PersistentVolume` の `lost+found` を削除すること(以下参考)

```yaml
initContainers:
- name: alpine
  image: alpine
  command: ["rm", "-rf", "/data/lost+found"]
  volumeMounts:
  - name: data-volume
    mountPath: /data
```
