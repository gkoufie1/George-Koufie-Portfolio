# Single-stage build: copy static files into nginx
FROM nginx:1.29-alpine

# Remove default NGINX static content
RUN rm -rf /usr/share/nginx/html/*

# Copy portfolio files into the container
COPY index.html /usr/share/nginx/html/
COPY robots.txt /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/
COPY resume/ /usr/share/nginx/html/resume/

# Copy custom NGINX config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
