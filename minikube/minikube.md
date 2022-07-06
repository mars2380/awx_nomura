https://github.com/ansible/awx-operator

# Install AWX on Mac
minikube stop
minikube -p minikube delete
minikube profile list
minikube delete --purge
<!-- minikube start --cpus=4 --memory=4g --addons=ingress -->
minikube start --addons=ingress
minikube kubectl -- get nodes
minikube kubectl -- get pods -A
# create kustomization.yaml
kustomize build . | kubectl apply -f -
kubectl get pods -n awx
kubectl config set-context --current --namespace=awx
# create awx-demo.yaml
# uncommenet 'awx-demo.yaml'
kustomize build . | kubectl apply -f -
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"


export NAMESPACE=awx
minikube service awx-demo-service --url -n $NAMESPACE
<!-- nohup minikube tunnel & -->
kubectl port-forward service/awx-demo-service 8080:80 &> /dev/null &
curl -L http://127.0.0.1:8080

kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode
# remove the '%' in the end of the password

# List minikube images before AWX
minikube image list
```
➜ minikube (main) ✗ minikube image ls
k8s.gcr.io/pause:3.6
k8s.gcr.io/kube-scheduler:v1.23.3
k8s.gcr.io/kube-proxy:v1.23.3
k8s.gcr.io/kube-controller-manager:v1.23.3
k8s.gcr.io/kube-apiserver:v1.23.3
k8s.gcr.io/etcd:3.5.1-0
k8s.gcr.io/coredns/coredns:v1.8.6
gcr.io/k8s-minikube/storage-provisioner:v5
docker.io/kubernetesui/metrics-scraper:v1.0.7
docker.io/kubernetesui/dashboard:v2.3.1
```
# List minikube images after AWX
```
➜ ~ minikube image list
quay.io/centos/centos:stream8
quay.io/ansible/awx:21.1.0
quay.io/ansible/awx-operator:0.22.0
quay.io/ansible/awx-ee:latest
k8s.gcr.io/pause:3.6
k8s.gcr.io/kube-scheduler:v1.23.3
k8s.gcr.io/kube-proxy:v1.23.3
k8s.gcr.io/kube-controller-manager:v1.23.3
k8s.gcr.io/kube-apiserver:v1.23.3
k8s.gcr.io/ingress-nginx/kube-webhook-certgen:<none>
k8s.gcr.io/ingress-nginx/controller:<none>
k8s.gcr.io/etcd:3.5.1-0
k8s.gcr.io/coredns/coredns:v1.8.6
gcr.io/kubebuilder/kube-rbac-proxy:v0.8.0
gcr.io/k8s-minikube/storage-provisioner:v5
docker.io/library/redis:latest
docker.io/library/postgres:12
docker.io/kubernetesui/metrics-scraper:v1.0.7
docker.io/kubernetesui/dashboard:v2.3.1
```

# Save minikube images
`minikube image save quay.io/ansible/awx:21.1.0 awx.tar`
# Load minikube images
`minikube image load awx.tar`

# WebServer
Spin up Redhat instance

```bash
export HOST=13.40.163.216
open http://$HOST/minikube

scp -v -i "../adm.pem" *.yaml ec2-user@$HOST:
ssh -i "../adm.pem" ec2-user@$HOST

sudo yum update -y
sudo yum install httpd docker git tmux -y
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl status httpd

sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /bin/minikube
alias kubectl="minikube kubectl --"
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo cp kustomize /usr/local/bin/

# minikube start --driver=docker
# minikube start --driver=podman

minikube start --addons=ingress
minikube kubectl -- get nodes
minikube kubectl -- get pods -A

ll kustomization.yaml

kustomize build . | kubectl apply -f -
kubectl get pods -n awx
kubectl config set-context --current --namespace=awx

ll awx-demo.yaml

sed 's/# - awx-demo.yaml/- awx-demo.yaml/' kustomization.yaml > kustomization_node.yaml
mv -v kustomization_node.yaml kustomization.yaml
kustomize build . | kubectl apply -f -
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager

kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator" -w

sudo mkdir -p /var/www/html/minikube/
# sudo cp -v /usr/local/bin/kustomize /var/www/html/minikube/
# sudo cp /usr/local/bin/kustomize .
sudo tar czvf /var/www/html/minikube/kustomize.tar kustomize

tmux
# detached
"ctrl + b + d"
tmux detach
# atached
"ctrl + b + a"
"tmux attach -t 0"
# List sessions
"tmux ls"

for i in $(minikube image list); do
  TAR=$(echo $i | awk -F '/' '{print $NF}' | sed 's/:/_/g;s/\./-/g')
  echo "Saving $TAR in progress...."
  # echo "minikube image save $i $TAR.tar"
  minikube image save $i $TAR.tar
  sudo cp -v $TAR.tar /var/www/html/minikube/
done

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
export HOST=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4`

echo $HOST
echo | sudo tee /var/www/html/minikube/wget_list.txt

echo "wget http://$HOST/minikube/kustomize.tar" | sudo tee -a /var/www/html/minikube/wget_list.txt
echo "tar xzvf kustomize.tar && cp kustomize /usr/local/bin/kustomize" | sudo tee -a /var/www/html/minikube/wget_list.txt

for i in $(minikube image list); do
  TAR=$(echo $i | awk -F '/' '{print $NF}' | sed 's/:/_/g;s/\./-/g')
  echo "Saving $TAR in progress...."
  echo "wget http://$HOST/minikube/$TAR.tar" | sudo tee -a /var/www/html/minikube/wget_list.txt
done

for i in $(minikube image list); do
  TAR=$(echo $i | awk -F '/' '{print $NF}' | sed 's/:/_/g;s/\./-/g')
  echo "Saving $TAR in progress...."
  echo "minikube image load $TAR.tar" | sudo tee -a /var/www/html/minikube/wget_list.txt
done

for i in $(minikube image list); do
  TAR=$(echo $i | awk -F '/' '{print $NF}' | sed 's/:/_/g;s/\./-/g')
  echo "Saving $TAR in progress...."
  # UNTAR=$(echo $TAR | sed 's/_/:/g;s/-/./g')
  # echo "Loading image $UNTAR"
done

# Install Kustomize by pulling docker images.
docker pull k8s.gcr.io/kustomize/kustomize:v3.8.7
docker run k8s.gcr.io/kustomize/kustomize:v3.8.7 version
docker image save k8s.gcr.io/kustomize/kustomize:v3.8.7 -o kustomize_v3-8-7.tar
sudo cp -v kustomize_v3-8-7.tar /var/www/html/minikube/
echo "wget http://$HOST/minikube/kustomize_v3-8-7.tar" | sudo tee -a /var/www/html/minikube/wget_list.txt
echo "docker image load -i kustomize_v3-8-7.tar" | sudo tee -a /var/www/html/minikube/wget_list.txt

docker run -d --name kustomize ubuntu sleep 3600
docker exec -it kustomize bash
  apt update && \
  apt install curl -y && \
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
  cp -v kustomize /bin && \
  kustomize version
docker exec kustomize kustomize

docker pull k8s.gcr.io/kustomize/kustomize:v3.8.7
docker run k8s.gcr.io/kustomize/kustomize:v3.8.7 version

# Set Global variables
cat > /etc/environment << EOL
export https_proxy=http://applicationwebproxy.nomura.com:8080
export http_proxy=http://applicationwebproxy.nomura.com:8080
export no_proxy=localhost,127.0.0.1,192.168.99.0/24,192.168.39.0/24,10.96.0.0/12,container-registry.nomura.com
EOL

# Point /var docjker subfolder to a different place
mkdir -p /local/default/var_lib_docker/
cp -vr /var/lib/docker/* /local/default/var_lib_docker/
cd /var/lib/
mv docker docker.bak
ln -s /local/default/var_lib_docker/ docker
```
