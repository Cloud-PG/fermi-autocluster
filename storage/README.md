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
mkdir data:/data
docker compose up -d
```

## Add a user with read-write access

```bash
docker exec -ti minio_minio_client_1 sh
~ mc --insecure admin user add myminio readwrite p6s54RT2b
~ mc --insecure admin policy set myminio readwrite user=readwrite
```

