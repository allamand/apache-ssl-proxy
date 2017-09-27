# Apache Httpd SSL Proxy

<!-- TOC -->

- [Apache Httpd SSL Proxy](#apache-httpd-ssl-proxy)
    - [Get the image](#get-the-image)
    - [Configure apache-ssl-proxy](#configure-apache-ssl-proxy)
        - [Create DHE Param](#create-dhe-param)
        - [Enable Basic Access authentication](#enable-basic-access-authentication)
        - [Add additional Apache httpd configuration](#add-additional-apache-httpd-configuration)
        - [Generate SSL Certificates](#generate-ssl-certificates)
        - [Verification of CSR](#verification-of-csr)
    - [Launch a Container](#launch-a-container)

<!-- /TOC -->

This repository is used to build a Docker image that acts as an HTTP [reverse proxy](http://en.wikipedia.org/wiki/Reverse_proxy) with optional (but strongly encouraged)
support for acting as an [SSL termination proxy](http://en.wikipedia.org/wiki/SSL_termination_proxy).
The proxy can also be configured to enforce [HTTP basic access authentication](http://en.wikipedia.org/wiki/Basic_access_authentication)

[Apache httpd](https://httpd.apache.org/) is the HTTP server, and its SSL configuration is included (and can be modified to suit your needs) in `apache/httpd.conf` in this repository.

## Get the image

You can retrieve the image from Docker Hub :

```bash
docker pull sebmoule/apache-ssl-proxy
```

Or you can build the image yourself by cloning this repository and running :

```bash
make build
```

## Configure apache-ssl-proxy

To run an SSL termination proxy you must have an existing SSL certificate and key. These instructions assume they are stored at /path/to/secrets and named
**myserver.crt** and **myserver.pem**. You'll need to change those values based on your actual file path and names.

### Create DHE Param

The Apache SSL configuration for this image also requires that you generate your own DHE parameter. It's easy and takes just a few minutes to complete :

```bash
openssl dhparam -out /path/to/secrets/dhparam.pem 2048
```

### Enable Basic Access authentication

Create an htpasswd file :

```bash
htpasswd -nb you_USERNAME SUPER_SECRET_PASSWORD > $PWD/htpasswd
```

### Add additional Apache httpd configuration

All .conf from apache/extra are added during the build to /etc/apache2/extra and get included on startup of the container.
Using volumes you can overwrite them on start of the container:

```bash
docker run \
  -e ENABLE_SSL=true \
  -e TARGET_SERVICE=THE_ADDRESS_OR_HOST_YOU_ARE_PROXYING_TO \
  -v /path/to/secrets/cert.crt:/etc/secrets/proxycert \
  -v /path/to/secrets/key.pem:/etc/secrets/proxykey \
  -v /path/to/secrets/dhparam.pem:/etc/secrets/dhparam \
  -v /path/to/additional-nginx.conf:/etc/nginx/extra-conf.d/additional_proxy.conf \
  nginx-ssl-proxy
```

That way it is possible to setup additional proxies or modifying the apache configuration

### Generate SSL Certificates

We can generate Auto-signed SSL certificates using docker image `CertUtil`

We gives your IP or domain name to the container and it will create a CSR so you can ask a verified certificate, but it will also generate an auto-signed certificate so that you can continue for testing

```bash
$ make IP=84.39.10.12

Creating 84.39.10.12 repository
mkdir 84.39.10.12
Create conf file
cp openssl.cnf.tpl 84.39.10.12/openssl.cnf
sed -i "s/{{ IP }}/84.39.10.12/g" 84.39.10.12/openssl.cnf
generate server key
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out 84.39.10.12/84.39.10.12.xip.io.key.pem -outform pem
```

openssl req -new -config 84.39.10.12/openssl.cnf -sha256 -key 84.39.10.12/84.39.10.12.xip.io.key.pem -keyform pem -subj "/C=FR/ST=Alpes\ Maritimes/L=Sophia/O=Oran\
ge/OU=Hebex/CN=84.39.10.12.xip.io/emailAddress=dfy.hbx.sec.all@list.orangeportails.net" -out 84.39.10.12/84.39.10.12.xip.io.csr.pem -outform pem -verbose

### Verification of CSR

```bash
openssl req -in 84.39.10.12/84.39.10.12.xip.io.csr.pem -noout -text
```

## Launch a Container

Modify the below command to include the actual adress or host name you want to proxy to, as well as the correct /path/to/secrets for your certificate, and password file:

```bash
docker run -ti \
-e ENABLE_SSL=true \
-e ENABLE_BASIC_AUTH=true \
-e TARGET_SERVICE=backend.com \
-v $PWD/myserver.crt:/apache/myserver.crt \
-v $PWD/myserver.key:/apache/myserver.key \
-v $PWD/htpasswd:/apache/htpasswd \
allamand/apache-ssl-proxy
```

- If you specify **ENABLE_SSL** you need to provide the volume with the **myserver.crt** and **myserver.key** files
- If you specify **ENABLE_BASIC_AUTH** you need to provide the volume with the **htpasswd** file
- Edit the **TARGET_SERVICE** with the target you want to proxify to

or if you've clone the repo just run :

```bash
make run
```
