FROM nginx:latest


#RUN groupadd -r blaster && useradd -r -g blaster -m -s /bin/bash blaster
#RUN echo "blaster:droid7" | chpasswd

# Create necessary directories for SSL certificates
RUN mkdir -p /etc/nginx/certs/droid7.ddns.net \
    && mkdir -p /etc/nginx/certs/mixitup-endpoint.ddns.net \
    && mkdir -p /etc/nginx/certs/blaster.ddns.net \
    && mkdir -p /etc/nginx/conf.d \
    && mkdir -p /var/log/nginx/

# Install necessary debugging tools and Certbot
#RUN apt-get update && apt-get install -y \
#    iputils-ping \
#    curl \
#    net-tools \
#    certbot \
#    python3-certbot-nginx \
#    && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /etc/nginx/sites-available && \
    chmod 755 /etc/nginx/sites-available

RUN mkdir -p /etc/nginx/sites-enabled && \
    chmod 755 /etc/nginx/sites-enabled 


# Set the correct permissions on /data/media and its subdirectories
#RUN mkdir -p /blaster-cms/data && \
#    chown -R www-data:www-data /blaster-cms/data && \
#    chmod -R 775 /blaster-cms/data 


# Create the /data/media directory
RUN mkdir -p /app/staticfiles_collected \ 
            /app/backend/static \
            /app/backend/templates \
            /app/backend/plugins \            
            /app/backend \
            /app/scripts \
            /app/data/media \
            /app/data 

# RUN usermod -aG blaster www-data


# Copy the files from your local nginx-config into the container's sites-available
# COPY /etc/nginx/sites-available/* /etc/nginx/sites-available/

# Create symlinks in sites-enabled pointing to the files in sites-available inside the container
# RUN for f in /etc/nginx/sites-available/*; do \
#        ln -sf $f /etc/nginx/sites-enabled/$(basename $f); \




# Expose ports for HTTP and HTTPS
EXPOSE 80 443


