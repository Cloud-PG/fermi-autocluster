# Deploy on k8s with Ansible

## Requirements

- Ansible
- git
- kubectl and a valid KUBECONFIG env var
- K8s cluster with master on public IP, and 2 other nodes with a publicIP with ports 9618 and [31024, 32048] opened. For user registration schedd will also need prot 48080.

## Values

```yaml
collector_node_name:
schedd_node_name:

schedd_pub_ip:
condor_pub_ip:
master_priv_ip:

cvmfs:
    key: |

    url:


iam:
    client-secret:
    client-id:
    access-token:
    token-endpoint:
    credential-endpoint:

spool:
    pv-size:
    pvc-size:

minio:
  pv-size:
  pvc-size:
  endpoint:
  access_key_id:
  access_key_key:
```

## Deploy

```bash
ansible-playbook --extra-values "@values.yaml" compute/deploy.yaml
```

## Use Terraform for k8s cluster creation on OpenStack (Coming soon...)

## Use InfrastructureManager for k8s cluster creation on OpenStack (Coming soon...)