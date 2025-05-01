.PHONY: boot-cluster create-cluster vela-install vela-addons vela-pf apply-base delete-base delete-cluster

CLUSTER_NAME := tools
BIND_IP := 100.101.148.63
VOLUME := /data
KUBECONFIG := ~/.kube/config

boot-cluster: create-cluster .WAIT vela-install .WAIT vela-addons

create-cluster:
	k3d cluster create $(CLUSTER_NAME) --api-port $(BIND_IP):6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 1 --volume $(VOLUME):/var/lib/rancher/k3s/storage@all
	kubectx k3d-$(CLUSTER_NAME)

vela-install:
	vela install

vela-addons:
	vela addon enable velaux
	vela addon enable fluxcd
	vela addon enable vela-workflow

vela-pf:
	vela port-forward -n vela-system addon-velaux 8000:8000

capacitor:
	kubectl port-forward -n flux-system svc/capacitor 9000:9000

apply-base:
	vela up -f clusters/production/base.yaml

delete-base:
	vela delete base -n default

delete-cluster:
	k3d cluster delete $(CLUSTER_NAME)