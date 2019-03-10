upstream instaghub {
   server 127.0.0.1:4000;
}

server {
  server_name www.instaghub.com instaghub.com;
  if ($host = instaghub.com) {
      return 301 https://www.instaghub.com$request_uri;
  } # managed by Certbot
  location / {
    allow all;
    # Proxy Headers
    proxy_pass http://instaghub;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-Cluster-Client-Ip $remote_addr;
    # WebSockets
    # proxy_set_header Upgrade $http_upgrade;
    # proxy_set_header Connection "Upgrade";

  }
  location = /robots.txt {
     add_header Content-Type text/plain;
     return 200 "User-agent: *\nDisallow: /search\nDisallow: /search/\nDisallow: /privacy\nDisallow: /about\nUser-agent: dotbot\nDisallow: /\nUser-agent: MJ12bot\nDisallow: /\nUser-agent: Cliqzbot\nDisallow: /\nUser-agent: grapeshot\nDisallow: /\nUser-agent: SeznamBot\nDisallow: /";
  }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/instaghub.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/instaghub.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = www.instaghub.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    if ($host = instaghub.com) {
        return 301 https://www.instaghub.com$request_uri;
    } # managed by Certbot

  listen 80 default_server;
  listen [::]:80 default_server;
  server_name instaghub.com www.instaghub.com;
    return 404; # managed by Certbot
}
