# Setup your own user UI

## Requirements

- The guide is made for CENTOS-7 machines
- Register an account [here](https://dodas-iam.cloud.cnaf.infn.it). You can use your IdP because IAM-DODAS supports eduGAIN identity federation. The first registration will require the approval from the DODAS admins.
    - wait for approval, if within 24h you do not receive any answer please send an email/slack message to the support
- [Setup OIDC-agent](https://dodas-ts.github.io/dodas-apps/setup-oidc/)
- Install condor client, voms client and CA certificates:

```bash
yum -y install epel-release
cd /etc/yum.repos.d/ \
    && wget http://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-stable-rhel7.repo \
    && wget http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor \
    && rpm --import RPM-GPG-KEY-HTCondor \
    && yum update -y && yum install -y condor-all-8.8.2
yum install -y voms-clients-cpp globus-proxy-utils fetch-crl
wget -O /etc/yum.repos.d/ca_CMS-TTS-CA.repo https://ci.cloud.cnaf.infn.it/view/dodas/job/ca_DODAS-TTS/job/master/lastSuccessfulBuild/artifact/ca_DODAS-TTS.repo
yum -y install ca_DODAS-TTS
fetch-crl -q

# Download doc material
git clone https://github.com/DODAS-TS/dodas-apps.git
cd dodas-apps
```

- [Dowload tts-cache service app](https://github.com/DODAS-TS/dodas-ttsInK8s/releases/download/v0.0.1/tts-cache) 
- Install rclone with:

```bash
curl https://rclone.org/install.sh | sudo bash
```

## Access data on your machine

### Configure the access to the storage

Let's configure rclone for accessing you data:

```bash
$ rclone config
```

A guided procedure will start. Follow the steps below to configure it properly.

Create a new configuration typing n then enter.

```text
e) Edit existing remote
n) New remote
d) Delete remote
r) Rename remote
c) Copy remote
s) Set configuration password
q) Quit config
e/n/d/r/c/s/q> n
```

Provide a name for the configuration (e.g. fermi):

```text
name> fermi
```

Type 4+enter where asked for storage type:

```text
Type of storage to configure.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / 1Fichier
   \ "fichier"
 2 / Alias for an existing remote
   \ "alias"
 3 / Amazon Drive
   \ "amazon cloud drive"
 4 / Amazon S3 Compliant Storage Provider (AWS, Alibaba, Ceph, Digital Ocean, Dreamhost, IBM COS, Minio, etc)
   \ "s3"
 5 / Backblaze B2
   \ "b2"
 6 / Box
   \ "box"
 7 / Cache a remote
   \ "cache"
 8 / Citrix Sharefile
   \ "sharefile"
 9 / Dropbox
   \ "dropbox"
10 / Encrypt/Decrypt a remote
   \ "crypt"
11 / FTP Connection
   \ "ftp"
12 / Google Cloud Storage (this is not Google Drive)
   \ "google cloud storage"
13 / Google Drive
   \ "drive"
14 / Google Photos
   \ "google photos"
15 / Hubic
   \ "hubic"
16 / In memory object storage system.
   \ "memory"
17 / Jottacloud
   \ "jottacloud"
18 / Koofr
   \ "koofr"
19 / Local Disk
   \ "local"
20 / Mail.ru Cloud
   \ "mailru"
21 / Mega
   \ "mega"
22 / Microsoft Azure Blob Storage
   \ "azureblob"
23 / Microsoft OneDrive
   \ "onedrive"
24 / OpenDrive
   \ "opendrive"
25 / OpenStack Swift (Rackspace Cloud Files, Memset Memstore, OVH)
   \ "swift"
26 / Pcloud
   \ "pcloud"
27 / Put.io
   \ "putio"
28 / QingCloud Object Storage
   \ "qingstor"
29 / SSH/SFTP Connection
   \ "sftp"
30 / Sugarsync
   \ "sugarsync"
31 / Tardigrade Decentralized Cloud Storage
   \ "tardigrade"
32 / Transparently chunk/split large files
   \ "chunker"
33 / Union merges the contents of several upstream fs
   \ "union"
34 / Webdav
   \ "webdav"
35 / Yandex Disk
   \ "yandex"
36 / http Connection
   \ "http"
37 / premiumize.me
   \ "premiumizeme"
38 / seafile
   \ "seafile"
Storage> 4
```


Type 7+enter where asked for provider type:

```text
Choose your S3 provider.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / Amazon Web Services (AWS) S3
   \ "AWS"
 2 / Alibaba Cloud Object Storage System (OSS) formerly Aliyun
   \ "Alibaba"
 3 / Ceph Object Storage
   \ "Ceph"
 4 / Digital Ocean Spaces
   \ "DigitalOcean"
 5 / Dreamhost DreamObjects
   \ "Dreamhost"
 6 / IBM COS S3
   \ "IBMCOS"
 7 / Minio Object Storage
   \ "Minio"
 8 / Netease Object Storage (NOS)
   \ "Netease"
 9 / StackPath Object Storage
   \ "StackPath"
10 / Wasabi Object Storage
   \ "Wasabi"
11 / Any other S3 compatible provider
   \ "Other"
provider> 7
```

Type 1+enter where asked for credentials type:

```text
Get AWS credentials from runtime (environment variables or EC2/ECS meta data if no env vars).
Only applies if access_key_id and secret_access_key is blank.
Enter a boolean value (true or false). Press Enter for the default ("false").
Choose a number from below, or type in your own value
 1 / Enter AWS credentials in the next step
   \ "false"
 2 / Get AWS credentials from the environment (env vars or IAM)
   \ "true"
env_auth> 1
```

Then insert the access key that has to be passed to you by the storage admin:
```text
AWS Access Key ID.
Leave blank for anonymous access or runtime credentials.
Enter a string value. Press Enter for the default ("").
access_key_id> <PUT HERE YOUR ACCESSKEY>
```

Then insert the secret access key that has to be passed to you by the storage admin:

```text
AWS Secret Access Key (password)
Leave blank for anonymous access or runtime credentials.
Enter a string value. Press Enter for the default ("").
secret_access_key> <PUT HERE YOUR SECRET ACCESSKEY>
```

Just press enter at the next question:

```text
Region to connect to.
Leave blank if you are using an S3 clone and you don't have a region.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / Use this if unsure. Will use v4 signatures and an empty region.
   \ ""
 2 / Use this only if v4 signatures don't work, eg pre Jewel/v10 CEPH.
   \ "other-v2-signature"
region> 
```

Then insert the endpoint that has to be passed to you by the storage admin:

```text
Endpoint for S3 API.
Required when using an S3 clone.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
endpoint> <PUT YOUR ENDPOINT HERE>
```

Just press enter at all the next questions:

```text
Location constraint - must be set to match the Region.
Leave blank if not sure. Used when creating buckets only.
Enter a string value. Press Enter for the default ("").
location_constraint>

Canned ACL used when creating buckets and storing or copying objects.

This ACL is used for creating objects and if bucket_acl isn't set, for creating buckets too.

For more info visit https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl

Note that this ACL is applied when server side copying objects as S3
doesn't copy the ACL from the source but rather writes a fresh one.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / Owner gets FULL_CONTROL. No one else has access rights (default).
   \ "private"
 2 / Owner gets FULL_CONTROL. The AllUsers group gets READ access.
   \ "public-read"
   / Owner gets FULL_CONTROL. The AllUsers group gets READ and WRITE access.
 3 | Granting this on a bucket is generally not recommended.
   \ "public-read-write"
 4 / Owner gets FULL_CONTROL. The AuthenticatedUsers group gets READ access.
   \ "authenticated-read"
   / Object owner gets FULL_CONTROL. Bucket owner gets READ access.
 5 | If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
   \ "bucket-owner-read"
   / Both the object owner and the bucket owner get FULL_CONTROL over the object.
 6 | If you specify this canned ACL when creating a bucket, Amazon S3 ignores it.
   \ "bucket-owner-full-control"
acl> 

The server-side encryption algorithm used when storing this object in S3.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / None
   \ ""
 2 / AES256
   \ "AES256"
 3 / aws:kms
   \ "aws:kms"

If using KMS ID you must provide the ARN of Key.
Enter a string value. Press Enter for the default ("").
Choose a number from below, or type in your own value
 1 / None
   \ ""
 2 / arn:aws:kms:*
   \ "arn:aws:kms:us-east-1:*"
sse_kms_key_id> 


Edit advanced config? (y/n)
y) Yes
n) No (default)
y/n>
```

Then hit q to exit and you are ready to mount your space locally.

### Mount your space locally

Mount your space (for instance in `$HOME/mydata`) on you laptop with the following command:

```bash
rclone mount --daemon --no-check-certificate --vfs-cache-max-size 4G  --vfs-cache-mode full fermi:/ $HOME/mydata
```

At this point you should be able to navigate in `$HOME/mydata`, to see all your files in `users/<username>` and to create new ones.

## Submit jobs via HTCondor

Follow the instructions [here](https://dodas-ts.github.io/dodas-apps/condor-user/)