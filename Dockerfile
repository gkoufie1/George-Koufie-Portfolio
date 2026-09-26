# Local development preview only — production hosting is AWS Amplify
# Hosting (static, no container). Single-stage build: copy static files into nginx.
FROM nginx:1.29-alpine

# Remove default NGINX static content
RUN rm -rf /usr/share/nginx/html/*

# Copy portfolio files into the container
COPY index.html /usr/share/nginx/html/
COPY robots.txt /usr/share/nginx/html/
COPY sitemap.xml /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/
COPY resume/ /usr/share/nginx/html/resume/

# Copy custom NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Run as the unprivileged nginx user instead of defaulting to root
# (SonarCloud docker:S6471). Requires listening on an unprivileged port -
# see nginx.conf (8080, not 80) - and the nginx user needs write access to
# its cache/log dirs and PID file, which are root-owned by default. Only
# those runtime paths are handed over; the web root and config stay
# root-owned and read-only to nginx, so a compromised worker can't rewrite
# the site or its own config.
RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid
USER nginx

# Expose port 8080 (unprivileged - see USER nginx above)
EXPOSE 8080

# Container health (Checkov CKV_DOCKER_2). 127.0.0.1, not localhost: busybox
# wget may resolve localhost to ::1, and nginx only listens on IPv4 here.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:8080/ || exit 1

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
