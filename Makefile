CLUSTER_NAME := tools
BIND_IP := 100.101.148.63
VOLUME := /data

bootstrap:
	echo "Bootstrapping cluster..."
	k3d cluster create $(CLUSTER_NAME) --api-port $(BIND_IP):6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 1 --volume $(VOLUME):/var/lib/rancher/k3s/storage@all
	kubectx k3d-tools
	vela install
	vela addon enable velaux
	vela addon enable fluxcd
	vela addon enable vela-workflow

apply-base:
	vela up -f clusters/production/base.yaml