FROM httpd:2.4

MAINTAINER Sebastien Allamand <sebastien@allamand.com>

COPY startup.sh /
COPY httpd.conf /apache/httpd.conf


#/usr/local/apache2/htdocs/
#/usr/local/apache2/conf/httpd.conf
#SSL mount server.crt & server.key in /usr/local/apache2/conf
#Include conf/extra/httpd-ssl.conf

ENTRYPOINT ["/startup.sh"]
CMD ["httpd"]