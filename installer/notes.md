docker tag redis:latest adimicoli/redis
docker tag postgres:12 adimicoli/postgres:12
docker tag quay.io/ansible/awx adimicoli/awx

docker push adimicoli/redis
docker push adimicoli/postgres:12
docker push adimicoli/awx

docker tag ansible/awx:17.1.0 awx:17.1.0
docker image save awx:17.1.0 -o awx:17.1.0.tar
docker image save redis -o redis.tar
docker image save postgres -o postgres.tar

docker image load -i awx:17.1.0.tar
docker image load -i redis.tar
docker image load -i postgres.tar