#!/usr/bin/env bash

TLSFILENAME=localhost
COMMONNAME=localhost
NGINXDIR=/usr/local/etc/nginx

generate_and_sign_certificate() {
  openssl genrsa -out $TLSFILENAME.key 2048
  openssl req -new -key $TLSFILENAME.key -out $TLSFILENAME.csr -sha256 -subj /C=DE/ST=Berlin/L=Berlin/OU=Development/CN=$COMMONNAME
  openssl x509 -req -days 3650 -in $TLSFILENAME.csr -signkey $TLSFILENAME.key -out $TLSFILENAME.crt
  rm $TLSFILENAME.csr
  chmod 600 $TLSFILENAME.key
}

copy_key_and_certificate() {
  cp -i $TLSFILENAME.* ${NGINXDIR}/
}


update_nginx_conf() {
  # cut away the closing curly brace
  sed -i '' -e '$d' ${NGINXDIR}/nginx.conf

  cat >> ${NGINXDIR}/nginx.conf <<EOCONF
    # HTTPS server
    #
    server {
       ssl on;
       listen       443 ssl;
       server_name  localhost;
       ssl_certificate      $TLSFILENAME.crt;
       ssl_certificate_key  $TLSFILENAME.key;
       keepalive_timeout    60;
       ssl_session_cache    shared:SSL:10m;
       ssl_session_timeout  10m;
       ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;
       ssl_ciphers RC4:HIGH:!aNULL:!MD5;
       ssl_prefer_server_ciphers  on;
       location / {
           proxy_pass http://localhost:3000/;
           proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
           proxy_set_header        Accept-Encoding   "";
           proxy_set_header        Host            \$host;
           proxy_set_header        X-Real-IP       \$remote_addr;
           proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
           proxy_set_header        X-Forwarded-Proto \$scheme;
           add_header              Front-End-Https   on;
           proxy_redirect  off;
       }
    }
}
EOCONF
}

echo -en "\033[0;1mInstall \033[36mnginx\033[0;1m with Homebrew?\033[0m [Y|n] "
read homebrew
case $homebrew in
  [yY]* )
    brew install nginx
    echo
    ;;
  * )
    exit;;
esac

echo -en "\033[0;1mCreate a \033[36mself-signed SSL-certificate\033[0;1m with OpenSSL?\033[0m [Y|n] "
read certificate
case $certificate in
  [yY]* )
    generate_and_sign_certificate
    copy_key_and_certificate
    echo
    ;;
  * )
    exit;;
esac

echo -en "\033[0;1mAdd \033[36mTLS reverse proxy directives\033[0;1m to nginx.conf?\033[0m [Y|n] "
read nginxconf
case $nginxconf in
  [yY]* )
    update_nginx_conf
    echo -e "\033[1;43mTODO\033[0m run a sanity test with nginx -t"
    ;;
  * )
    echo output config and let user add it manually
    ;;
esac
echo

echo -en "\033[0;1mAutomatically \033[36mstart nginx at boot time\033[0;1m using launchctl?\033[0m [Y|n] "
read autostart
case $autostart in
  [yY]* )
    # TODO remove the following line(s)
    brew info nginx |tail -n 6
    echo
    echo -e "\033[1;43mTODO\033[0m sudo launchctl dance"
    ;;
  * )
    brew info nginx |tail -n 6
    ;;
esac
echo

echo -en "\033[0;1mStart \033[36mstart nginx\033[0;1m now?\033[0m [Y|n] "
read startnow
case $startnow in
  [yY]* )
    echo "Running with root's super-powers."
    sudo nginx
    ;;
  * )
    exit;;
esac
echo
