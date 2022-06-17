https://github.com/ansible/awx-operator

kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/0.12.0/deploy/awx-operator.yaml

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
kubectl get secret ansible-awx-admin-password -o jsonpath="{.data.password}" | base64 --decode

minikube stop
minikube delete --purge
minikube start --cpus=4 --memory=4g --addons=ingress
minikube kubectl -- get nodes
minikube kubectl -- get pods -A
kustomize build . | kubectl apply -f -
kubectl get pods -n awx
kubectl config set-context --current --namespace=awx
kustomize build . | kubectl apply -f -
kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"

kubectl port-forward service/awx-demo-service 8080:80 &> /dev/null &
curl -L http://127.0.0.1:8080

kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" | base64 --decode
# remove the '%' in the end of the password

# Save minikube images
minikube image save quay.io/ansible/awx:21.1.0 awx.tar
# Load minikube images
minikube image load awx.tar
