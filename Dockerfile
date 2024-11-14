# FROM python:3.11
FROM debian:bookworm

ENV PYTHONPATH="/app/lib/python3.11/site-packages:$PYTHONPATH"
ENV PATH="/app/bin:/app/usr/local/lib:/app/local/bin:$PATH"

RUN apt-get update && \
    apt-get install -y \
    postgresql-server-dev-all \
    build-essential \
    #libssl-dev \
    #zlib1g-dev \
    #libffi-dev \
    #libpq-dev \
    python3.11-dev \
    python3.11-venv \
    && apt-get clean

# Create blaster Linux user and group with home directory
RUN groupadd -r blaster && useradd -r -g blaster -m -s /bin/bash blaster && \
    echo "blaster:droid7" | chpasswd

RUN mkdir -p /app/staticfiles_collected \ 
            /app/backend/static \
            /app/backend/templates \
            /app/backend/plugins \            
            /app/backend \
            /app/scripts \
            /app/data/media \
            /app/data 

# COPY --chown=blaster:blaster . ./app
COPY --chown=blaster:blaster /backend /app/backend
COPY --chown=blaster:blaster /scripts /app/scripts
COPY --chown=blaster:blaster /data /app/data
COPY --chown=blaster:blaster requirements.txt /app
COPY --chown=blaster:blaster manage.py /app
COPY --chown=blaster:blaster .env-local /app

# take ownership of the /app directory itself
RUN chown -R blaster:blaster /app/staticfiles_collected
RUN chown -R blaster:blaster /app/backend/static
RUN chown -R blaster:blaster /app/backend
RUN chown -R blaster:blaster /app/data/media
RUN chown -R blaster:blaster /app/data
RUN chown -R blaster:blaster /app/scripts
RUN chown -R blaster:blaster /app/*
RUN chown -R blaster:blaster /app

RUN chmod -R 755 /app/staticfiles_collected
RUN chmod -R 755 /app/backend/static
RUN chmod -R 755 /app/data/media
RUN chmod -R 755 /app/data
RUN chmod -R 755 /app

RUN echo "/" && ls -l /
RUN echo "/app" && ls -l /app
RUN echo "/app/backend" && ls -l /app/backend
RUN echo "/scripts" && ls -l /app/scripts
RUN echo "/data" && ls -l /app/data

USER blaster

# Create the virtual environment and set permissions
RUN python3.11 -m venv /app && \
    chmod -R +x /app/bin/activate 

# Ensure the ssl module is available (test)
RUN /app/bin/python -c "import ssl; print(ssl.OPENSSL_VERSION)"

WORKDIR /app

RUN ls -l /app/bin

RUN /app/bin/activate && \
    /app/bin/pip install --upgrade pip && \
    /app/bin/pip install --upgrade pip-tools && \
    /app/bin/pip install --upgrade setuptools wheel && \
    /app/bin/pip install --no-deps --no-cache-dir -r requirements.txt

# Run Django collectstatic
RUN /app/bin/python manage.py collectstatic --noinput

ENV PORT=8000

# CMD /app/bin/uwsgi --http=0.0.0.0:$PORT --uid blaster --gid blaster --module=backend.wsgi --master --workers=4 --max-requests=1000 --lazy-apps --need-app --http-keepalive --harakiri 65 --vacuum --strict --single-interpreter --die-on-term --disable-logging --log-4xx --log-5xx --cheaper=2 --enable-threads --post-buffering=8192
