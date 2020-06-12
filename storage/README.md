# Install MINIO Server for FERMI

## Requirements
- docker
- docker-compose
- git clone of this repo

## Put CA certs and host cert on correct paths

```bash
 ls -l storage/certs/
total 8
drwxrwxr-x. 2 centos centos   40 May 18 07:43 CAs
-rw-------. 1 centos centos 1675 May 18 07:43 private.key
-rw-rw-r--. 1 centos centos 1164 May 18 07:43 public.crt

$ ls -l storage/certs/CAs/
total 8
-rw-------. 1 centos centos 1675 May 18 07:43 MINIO.key
-rw-rw-r--. 1 centos centos 1078 May 18 07:43 MINIO.pem
```

## Start the server and client containers

Change the admin password in `docker-compose.yaml` (both client and server container) file then run:

```bash
cd storage
mkdir data
docker compose up -d
```

## Add a user with read-write access

```bash
docker exec -ti minio_minio_client_1 sh
~ mc --insecure admin user add myminio readwrite p6s54RT2b
~ mc --insecure admin policy set myminio readwrite user=readwrite
~ cat > user.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObjectLegalHold",
        "s3:GetObjectLegalHold",
        "s3:GetObjectRetention",
        "s3:PutObjectRetention",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListAllMyBuckets",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::home/user/*"
      ],
      "Sid": ""
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:GetObjectLegalHold",
        "s3:GetObjectRetention",
        "s3:ListAllMyBuckets",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::home/*"
      ],
      "Sid": ""
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:GetObjectLegalHold",
        "s3:GetObjectRetention",
        "s3:ListAllMyBuckets",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::fermi/*"
      ],
      "Sid": ""
    }
  ]
}
EOF
~ mc admin --insecure policy add myminio user user.json
~ mc --insecure admin user add myminio user 6s54RT2bqMmUZD
~ mc --insecure admin policy set myminio user user=user
```
