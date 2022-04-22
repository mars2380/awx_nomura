docker tag redis:latest adimicoli/redis
docker tag postgres:12 adimicoli/postgres:12
docker tag quay.io/ansible/awx adimicoli/awx

docker push adimicoli/redis
docker push adimicoli/postgres:12
docker push adimicoli/awx

docker image save awx -o awx.tar
docker image save redis -o redis.tar
docker image save postgres -o postgres.tar

docker image load -i awx.tar
docker image load -i redis.tar
docker image load -i postgres.tar