upstream puma_blog {
  server unix:///home/blog/blog/shared/tmp/sockets/puma.sock fail_timeout=0;
}

server {
  listen 80 default_server;

  server_name tuvistavie.com;
  access_log /home/blog/blog/shared/log/nginx.access.log;
  error_log /home/blog/blog/shared/log/nginx.error.log;

  location / {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://puma_blog;
    # limit_req zone=one;
  }
}
