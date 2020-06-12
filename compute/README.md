# Deploy on k8s with Ansible

## Requirements

- Ansible
- git
- kubectl and a valid KUBECONFIG env var
- K8s cluster with:
    - master on public IP with open port 6443, 31900, 30443
    - 2 other nodes with a publicIP with ports 9618 and [31024, 32048] opened. For user registration schedd will also need port 48080 open on one of the two.

## Values

```yaml
schedd_pub_ip:
condor_pub_ip:
master_priv_ip:

collector_node_name: ""
schedd_node_name: ""

cvmfs:
    key: |
      KEY HERE
      sdsdasdasd
    url: http://193.204.89.114/cvmfs/fermi.local.repo


iam:
    clientSecret:
    clientID:
    accessToken:
    tokenEndpoint: https://dodas-iam.cloud.cnaf.infn.it//token
    credentialEndpoint: https://dodas-tts.cloud.cnaf.infn.it/api/v2/iam/credential

spool:
    pvSize: 10Gi
    pvcSize: 9Gi

minio:
  pvSize: 800Gi
  pvcSize: 799Gi
  endpoint: https://141.250.7.19:9000
  access_key_id: 
  access_key_key:
```

## Deploy

```bash
ansible-playbook --extra-values "@values.yaml" compute/deploy.yaml
```

## Use Terraform for k8s cluster creation on OpenStack (Coming soon...)

## Use InfrastructureManager for k8s cluster creation on OpenStack (Coming soon...)