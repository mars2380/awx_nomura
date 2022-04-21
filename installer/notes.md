docker tag redis:latest adimicoli/redis
docker tag postgres:12 adimicoli/postgres:12
docker tag quay.io/ansible/awx adimicoli/awx

docker push adimicoli/redis
docker push adimicoli/postgres:12
docker push adimicoli/awx