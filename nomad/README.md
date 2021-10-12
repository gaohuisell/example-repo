## 使用 nomad 创建 namespace 
```shell
nomad namespace apply -description "dev env for app instances." dev
```

## 使用 namespace 进行部署 jobs command
```shell
nomad job run -namespace=dev -var-file=./var/dev/common.hcl -var-file=./var/dev/nginx.hcl ./jobs/nginx/nomad.hcl
```
