########## INPUT VARIABLES ##############

variable "priv_network_name"{
  default = "fermi-net"
  #default = "private_net"
}

variable "pub_network_name"{
  default = "fisica7"
  #default = "public_net"
}

variable "master_image_id" {
  default = "cb87a2ac-5469-4bd5-9cce-9682c798b4e4"
  #default = "8f667fbc-40bf-45b8-b22d-40f05b48d060"
}

variable "slave_image_id" {
  default = "d9a41aed-3ebf-42f9-992e-ef0078d3de95"
  #default = "8f667fbc-40bf-45b8-b22d-40f05b48d060"
}

variable "master_flavor_name" {
  default = "m1.large"
  #default = "2cpu-4GB.dodas"
}

variable "slave_flavor_name" {
  default = "m1.large"
  #default = "2cpu-4GB.dodas"
}

variable "n_slaves" {
  default = 2
}

variable "mount_volumes" {
  default = 1
}

variable "volume_size" {
  default = 50
}

variable "iam_token" {
  default = ""
}

############ OPENSTACK VMS ################

provider "openstack" {
  user_name   = "spiga"
  tenant_name = "fermi"
  password    = "***"
  auth_url    = "http://:5000/v2.0"
  region      = "RegionOne"
}


## Create the keypair starting from the local pub file
resource "openstack_compute_keypair_v2" "cluster-keypair" {
  name = "cluster-keypair"
  public_key = file("key.pub")
  #public_key = "${file("/home/dciangot/Documents/key.pub")}"
}

## Prepare the volume for the spool dir
resource "openstack_blockstorage_volume_v2" "spool" {
  count = 1
  name        = "spool-dir"
  size        =  var.volume_size
}


# Prepare the needed floating IPs for master, schedd and ccb
resource "openstack_networking_floatingip_v2" "floatingip_master" {
  count = 1
  pool = var.priv_network_name
}

resource "openstack_networking_floatingip_v2" "floatingip_ccb" {
  count = 1
  pool = var.priv_network_name
}

resource "openstack_networking_floatingip_v2" "floatingip_schedd" {
  count = 1
  pool = var.priv_network_name
}


# Security groups for master, schedd and ccb
resource "openstack_compute_secgroup_v2" "secgroup_k8s_master" {
  name        = "secgroup_k8s_master"
  description = "security group for k8s with terraform"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }


  rule {
    from_port   = 30443
    to_port     = 30443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 6443
    to_port     = 6443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

}

resource "openstack_compute_secgroup_v2" "secgroup_k8s_ccb" {
  name        = "secgroup_k8s_ccb"
  description = "security group for k8s with terraform"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 9618
    to_port     = 9618
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 31024
    to_port     = 32048
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

}

resource "openstack_compute_secgroup_v2" "secgroup_k8s_schedd" {
  name        = "secgroup_k8s_schedd"
  description = "security group for k8s with terraform"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 9618
    to_port     = 9618
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 48080
    to_port     = 48080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 31024
    to_port     = 32048
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

}

# Create the VMs

resource "openstack_compute_instance_v2" "k8s-master" {
  count = 1
  name      = "master-${count.index}"
  image_id  = var.master_image_id
  flavor_name = var.master_flavor_name
  key_pair  = openstack_compute_keypair_v2.cluster-keypair.name
  security_groups = ["default", "${openstack_compute_secgroup_v2.secgroup_k8s_master.name}"]
  network {
    name = var.priv_network_name
    #access_network = true
  }

}

resource "openstack_compute_instance_v2" "k8s-ccb" {
  count = 1
  name      = "ccb-${count.index}"
  image_id  = var.master_image_id
  flavor_name = var.master_flavor_name
  key_pair  = openstack_compute_keypair_v2.cluster-keypair.name
  security_groups = ["default", "${openstack_compute_secgroup_v2.secgroup_k8s_ccb.name}"]
  network {
    name = var.priv_network_name
    #access_network = true
  }

}

resource "openstack_compute_instance_v2" "k8s-schedd" {
  count = 1
  name      = "schedd-${count.index}"
  image_id  = var.master_image_id
  flavor_name = var.master_flavor_name
  key_pair  = openstack_compute_keypair_v2.cluster-keypair.name
  security_groups = ["default", "${openstack_compute_secgroup_v2.secgroup_k8s_schedd.name}"]
  network {
    name = var.priv_network_name
    #access_network = true
  }

}

resource "openstack_compute_instance_v2" "k8s-nodes" {
  name      = "node-${count.index}"
  count = var.n_slaves
  image_id  = var.slave_image_id
  flavor_name = var.slave_flavor_name
  key_pair  = openstack_compute_keypair_v2.cluster-keypair.name
  security_groups = ["default"]

  network {
    name = var.priv_network_name
  }

  depends_on = [
    openstack_compute_instance_v2.k8s-master
    ]
}


# Attach floating IPs

resource "openstack_compute_floatingip_associate_v2" "floatingip_master" {
  count = 1
  floating_ip = openstack_networking_floatingip_v2.floatingip_master.0.address
  instance_id = openstack_compute_instance_v2.k8s-master.0.id
}

resource "openstack_compute_floatingip_associate_v2" "floatingip_ccb" {
  count = 1
  floating_ip = openstack_networking_floatingip_v2.floatingip_ccb.0.address
  instance_id = openstack_compute_instance_v2.k8s-ccb.0.id
}

resource "openstack_compute_floatingip_associate_v2" "floatingip_schedd" {
  count = 1
  floating_ip = openstack_networking_floatingip_v2.floatingip_schedd.0.address
  instance_id = openstack_compute_instance_v2.k8s-schedd.0.id
}


# Mount spool dir

resource "openstack_compute_volume_attach_v2" "attachments" {
   count       = 1
   instance_id = openstack_compute_instance_v2.k8s-schedd.0.id
   volume_id   = openstack_blockstorage_volume_v2.spool.0.id
   device = "/dev/vdc"
}

resource "null_resource" "mount_spool" {
  count = 1
  triggers = {
    attach = openstack_compute_volume_attach_v2.attachments.0.id,
    ip = openstack_compute_instance_v2.k8s-schedd.0.access_ip_v4
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python -y"]
    connection {
      type     = "ssh"
      user     = "ubuntu"
      host = openstack_compute_instance_v2.k8s-schedd.0.access_ip_v4
      private_key = file("key")
    }
  }
  
  provisioner "local-exec" {
	command = <<EOT
    sleep 600;
	  >schedd.ini;
	  echo "[schedd]" | tee -a jenkins-ci.ini;
	  echo "${openstack_compute_instance_v2.k8s-schedd.0.access_ip_v4} ansible_user=ubuntu ansible_ssh_private_key_file=key" | tee -a schedd.ini;
    export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -i schedd.ini mount.yaml
    EOT
  }

}


############### k8s deployment #############

# Install master

# --ssh-key
resource "null_resource" "install-master" {
    count = 1

    depends_on = [openstack_compute_instance_v2.k8s-master]
  
  provisioner "local-exec" {
	  command = "k3sup install --ssh-key key install --ip ${openstack_compute_instance_v2.k8s-master.0.access_ip_v4} --user ubuntu"
  }

}

resource "null_resource" "join-others" {
    count = 1

    depends_on = [null_resource.install-master]
  
    provisioner "local-exec" {
	  command = "k3sup install --ssh-key key join --ip ${openstack_compute_instance_v2.k8s-schedd.0.access_ip_v4[count.index]} --server-ip ${openstack_compute_instance_v2.k8s-master.0.access_ip_v4} --user ubuntu"
    }
    provisioner "local-exec" {
	  command = "k3sup install --ssh-key key join --ip ${openstack_compute_instance_v2.k8s-ccb.0.access_ip_v4[count.index]} --server-ip ${openstack_compute_instance_v2.k8s-master.0.access_ip_v4} --user ubuntu"
    }
}

resource "null_resource" "join-nodes" {
    count = var.n_slaves

    depends_on = [openstack_compute_instance_v2.k8s-nodes, null_resource.install-master]
  
    provisioner "local-exec" {
	command = "k3sup install --ssh-key key join --ip ${openstack_compute_instance_v2.k8s-nodes.*.access_ip_v4[count.index]} --server-ip ${openstack_compute_instance_v2.k8s-master.0.access_ip_v4} --user ubuntu"

  }
}

# deploy rclone csi
resource "null_resource" "deploy-rclone-csi" {
    depends_on = [null_resource.install-master]
  provisioner "local-exec" {
    command = "kubectl -n kube-system delete helmcharts.helm.cattle.io traefik"
    }
  provisioner "local-exec" {
    command="kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml"
    }
  provisioner "local-exec" {
    command= <<EOT
    git clone https://github.com/wunderio/csi-rclone.git;
    cd csi-rclone;
    kubectl apply -f deploy/kubernetes/;
    cd ..;
    rm -fr csi-rclone;
    EOT
  }
}

resource "null_resource" "deploy-condor" {

}

# resource "null_resource" "deploy-condor" {
#     count = 1

#     depends_on = [null_resource.install-master]

#   # compile template  
#     provisioner "local-exec" {
# 	command = <<EOT
#     sleep 600;
# 	  ansible-playbook deploy.yaml --extra-vars ${var.iam_token} -
#     EOT
#   }

#     # install app
#     provisioner "local-exec" {
# 	command = "kubectl apply -f manifest.yaml"
#     }
# }