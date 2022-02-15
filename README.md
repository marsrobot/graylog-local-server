# graylog-local-server

# Purpose
- Set up an intranet Graylog server.
- The stack is composed of Graylog, Elasticsearch, and MongoDB.

# Pros of Graylog
- Graylog is very reliable for message delivery and does not require tons of resources. The stack runs on 8GB server.
- Can handle thousands of messages per second.
- Graylog supports GELF protocol. Various languages support writing to Graylog.
- Python writes to Graylog by pygelf (https://pypi.org/project/pygelf/).
- Java writes to Graylog by org.graylog2 (https://stackoverflow.com/questions/26847569/how-to-get-gelfj-appender-work-in-log4j).
- PHP by monolog (https://stackoverflow.com/questions/36055878/to-send-logs-from-php-application-to-graylog-using-monolog).

# Cons of Graylog
- Not as fancy as ELK.
- Only suitable for medium sized team to use.

# Server setup
- Go to deployment/docker/graylog-server
- Change environment variable SERVER_IP in docker_run.sh to your server IP.
- Change environment variable USER in docker_run.sh to your regular username on the server.
- Run ./docker_run.sh

# Client usage
- Go to http://SERVER_IP:9000/ to see the Graylog website.

# Reference
- For general information on Graylog, check out https://www.graylog.org/
- For a docker-compose setup of the Graylog server, check out https://docs.graylog.org/docs/docker
- dockerhub: https://hub.docker.com/r/graylog2/server