# infra_ac4

Создаем ключи для доступа к бакету
```
yc iam access-key create --service-account-name infraterraform
access_key:
  id: aje...
  service_account_id: aje...
  created_at: "2024-05-21T10:00:30.227819147Z"
  key_id: YCA...
secret: YCM...
```
Инициализируем terraform
```
$ export ACCESS_KEY="YCA..."
$ export SECRET_KEY="YCM..."
$ terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"
```
