[ここ](https://gist.github.com/cstoku/8f5e4e718fa8ba5205147525164ccd6b) から引用

# No. 1

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
  containers:
  - name: web
    image: nginx:stable
    ports:
    - containerPort: 80
```

# No. 2

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:stable
        ports:
        - containerPort: 80
```

# No. 3

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
  type: LoadBalancer
```

# No. 4

```yaml
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: output-date
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: output-date
            image: alpine:latest
            command: ["date"]
          restartPolicy: Never
```

# No. 5

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: cache
spec:
  containers:
  - name: cache
    image: redis:5.0
    resources:
      limits:
        cpu: 100m
        memory: 32Mi
      requests:
        cpu: 10m
        memory: 8Mi
    ports:
    - containerPort: 6379
```

# No. 6

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
            - '/bin/true'
        readinessProbe:
          httpGet:
            path: '/index.html'
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

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: exam-cm
data:
  listen_port: "8888"
  content_body: |
    aaa
    bbb
    ccc
---
apiVersion: v1
kind: Secret
metadata:
  name: exam-secret
type: Opaque
data:
  secret_token: anI1bVUuNFRzTTg=
```

# No. 8

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tick-app
spec:
  selector:
    matchLabels:
      app: tick
  template:
    metadata:
      labels:
        app: tick
    spec:
      containers:
      - name: tick-app
        image: alpine:3.9
        command: ["sh", "-c"]
        args:
        - |
          touch /logs/tick.log
          while :; do
            date -Iseconds >> /logs/tick.log
            sleep 1
          done
        volumeMounts:
        - name: log-volume
          mountPath: /logs
      - name: fluentd
        image: fluent/fluentd:v1.4-1
        volumeMounts:
        - name: log-volume
          mountPath: /logs
        - name: fluent-config
          mountPath: /fluentd/etc
      volumes:
      - name: log-volume
        emptyDir:
      - name: fluent-config
        configMap:
          name: fluent-config
      terminationGracePeriodSeconds: 0
---
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