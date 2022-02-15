export DATA_DIR="/local"
export SERVER_IP="10.0.0.5"
export USER=ubuntu

export GRAYLOG_CONTAINER_NAME=graylog-local-server
export GRAYLOG_ES_CONTAINER_NAME=graylog-elasticsearch-local-server
export GRAYLOG_MONGO_CONTAINER_NAME=graylog-mongo-local-server
export GRAYLOG_NETWORK=graylognetwork

sudo docker rm -f $(sudo docker ps -a -q)
sudo docker network rm ${GRAYLOG_NETWORK}

sudo mkdir -p ${DATA_DIR}/var/lib/mongodb

sudo chown -R ${USER} ${DATA_DIR}/var/lib/mongodb

sudo docker network create ${GRAYLOG_NETWORK}

echo "Starting MongoDB..."
sudo docker stop ${GRAYLOG_MONGO_CONTAINER_NAME}
sudo docker rm -f ${GRAYLOG_MONGO_CONTAINER_NAME}
sudo docker run -it -d \
    --restart=unless-stopped \
    --privileged=true \
    --name ${GRAYLOG_MONGO_CONTAINER_NAME} \
    --expose=27017 \
    --network=${GRAYLOG_NETWORK} \
    -p 27017:27017 \
    -v ${DATA_DIR}/var/lib/mongodb:/data/db:rw \
    mongo:2

echo "Starting Elasticsearch..."
sudo docker stop ${GRAYLOG_ES_CONTAINER_NAME}
sudo docker rm -f ${GRAYLOG_ES_CONTAINER_NAME}

sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/0
sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/1
sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/2
sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/3
sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/4
sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/5
sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/6
sudo mkdir -p ${DATA_DIR}/var/lib/elasticsearch/data/nodes/7

sudo chown -R ${USER} ${DATA_DIR}/var/lib/elasticsearch

sudo docker run -it -d \
    --name ${GRAYLOG_ES_CONTAINER_NAME} \
    --restart=unless-stopped \
    --privileged=true \
    --network=${GRAYLOG_NETWORK} \
    -e "http.host=0.0.0.0" \
    -e "discovery.type=single-node" \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -p 9200:9200 \
    -p 9300:9300 \
    -v ${DATA_DIR}/var/lib/elasticsearch/data:/usr/share/elasticsearch/data:rw \
    docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2

echo "Starting Graylog..."
sudo docker stop ${GRAYLOG_CONTAINER_NAME}
sudo docker rm -f ${GRAYLOG_CONTAINER_NAME}

sudo iptables -I INPUT -p tcp --dport 1514 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 5555 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 9000 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 9200 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 12201 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 27017 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 1514 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 5555 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 9000 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 9200 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 12201 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 27017 -j ACCEPT

sudo docker run -it -d \
    --name ${GRAYLOG_CONTAINER_NAME} \
    --network=${GRAYLOG_NETWORK} \
    --restart=unless-stopped \
    --privileged=true \
    -p 0.0.0.0:1514:1514 \
    -p 0.0.0.0:5555:5555 \
    -p 0.0.0.0:9000:9000 \
    -p 0.0.0.0:12201:12201 \
    -p 0.0.0.0:1514:1514/udp \
    -p 0.0.0.0:5555:5555/udp \
    -p 0.0.0.0:12201:12201/udp \
    -e GRAYLOG_HTTP_EXTERNAL_URI="http://${SERVER_IP}:9000/" \
    -d graylog/graylog:4.0
