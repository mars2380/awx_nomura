https://github.com/ansible/awx-operator

<!-- kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/0.12.0/deploy/awx-operator.yaml

kubectl apply -f ./awx-operator.yaml
kubectl apply -f ./ansible-awx.yml
kubectl logs -f deployment/awx-operator
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"

devops@linuxtechi:~$ nohup minikube tunnel &
devops@linuxtechi:~$ kubectl get svc ansible-awx-service
NAME                  TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
ansible-awx-service   NodePort   10.97.206.89   <none>        80:32483/TCP   90m

kubectl port-forward svc/ansible-awx-service --address 0.0.0.0 32483:80 &> /dev/null &
open http://<minikube-ip>:<node-port>
kubectl get secret ansible-awx-admin-password -o jsonpath="{.data.password}" | base64 --decode -->

minikube stop
minikube -p minikube delete
minikube profile list
minikube delete --purge
minikube start --cpus=4 --memory=4g --addons=ingress
minikube kubectl -- get nodes
minikube kubectl -- get pods -A
kustomize build . | kubectl apply -f -
kubectl get pods -n awx
kubectl config set-context --current --namespace=awx
# uncommenet 'awx-demo.yaml'
kustomize build . | kubectl apply -f -
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"

<!-- export NAMESPACE=awx
minikube service awx-demo-service --url -n $NAMESPACE -->

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
minikube image save quay.io/ansible/awx:21.1.0 awx.tar
# Load minikube images
minikube image load awx.tar

# WebServer
Spin up Redhat instance

```bash
ssh -i "~/Downloads/adm.pem" ec2-user@ec2-18-133-65-63.eu-west-2.compute.amazonaws.com
sudo -i

sudo yum update -y

# sudo yum install nginx -y
# sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
# sudo sed -i '/^#/d' /etc/nginx/nginx.conf
# # sudo sed -i "/location \/ {/a\    index not_a_file;\n    autoindex on;\n    types {}" /etc/nginx/nginx.conf
# sudo sed -i "/location \/ {/\/location \minikube/ {    index not_a_file;\n    autoindex on;\n    types {}" /etc/nginx/nginx.conf
# sudo nginx -t
# sudo systemctl restart nginx
# sudo systemctl status nginx
# sudo echo 'This is a test' > /usr/share/nginx/html/minikube/minikube.html


sudo yum install -y vsftpd
sudo -i sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd/vsftpd.conf
sudo systemctl restart vsftpd.service
sudo systemctl status vsftpd.service

sudo yum install docker -y

sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /bin/minikube
alias kubectl="minikube kubectl --"

# minikube start --driver=docker
minikube start --driver=podman
sudo mkdir -p /usr/share/nginx/html/minikube/

sudo rm -rf /usr/share/nginx/html/minikube/*
for i in $(minikube image list); do
  TAR=$(echo $i | awk -F '/' '{print $NF}' | sed s/://)
  echo "Saving $TAR in progress...."
  # echo "minikube image save $i $TAR.tar"
  minikube image save $i $TAR
  sudo mv -v $TAR /usr/share/nginx/html/minikube/
done





```
