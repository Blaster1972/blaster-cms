FROM nginx:latest

# Copy custom configuration file
# COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy SSL certificates
# COPY nginx/certs /etc/nginx/certs/

# COPY /nginx /etc/nginx

# Create necessary directories for SSL certificates
RUN mkdir -p /etc/nginx/certs/droid7.ddns.net \
    && mkdir -p /etc/nginx/certs/mixitup-endpoint.ddns.net \
    && mkdir -p /etc/nginx/certs/blaster.ddns.net \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /var/log/nginx/

# Expose ports
EXPOSE 80 443