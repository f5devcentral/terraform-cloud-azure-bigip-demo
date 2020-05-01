# find the ip address of the created BIG-IP 
export NGINXVS0=`terraform output --json | jq -r '.nginx_ip.value[0]'`
# start the locust instance 
cd locust
locust --host=http://$NGINXVS0 --no-web -c 50 -r 2 --run-time 5m --csv=$NGINXVS0
cd ..