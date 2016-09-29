



build:
	docker build -t allamand/apache-ssl-proxy .


run:
	docker run -ti \
	-e ENABLE_SSL=true \
	-e ENABLE_BASIC_AUTH=true \
	-e TARGET_SERVICE=backend.com \
	-v $(shell pwd)/myserver.crt:/apache/myserver.crt \
	-v $(shell pwd)/myserver.key:/apache/myserver.key \
	-v $(shell pwd)/htpasswd:/apache/htpasswd \
	allamand/apache-ssl-proxy $(ARGS)


run_bash:
	docker run -ti -e ENABLE_SSL=true -v $(shell pwd)/myserver.crt:/apache/myserver.crt -v $(shell pwd)/myserver.key:/apache/myserver.key -v $(shell pwd)/htpasswd:/apache/htpasswd allamand/apache-ssl-proxy bash

run_nossl:
	docker run -ti -e ENABLE_SSL=false allamand/apache-ssl-proxy httpd

basic:
	docker run -ti apache-ssl-proxy htpasswd -c htpasswd dfy 
