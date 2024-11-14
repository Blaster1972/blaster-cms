#!/bin/sh

set -e  # Exit script on error

# Attempt to activate the virtual environment
if [ -f bin/activate ]; then    
    . /app/bin/activate
    echo "Virtual Environment Activated"
    echo "Python version: $(python --version)"
    # Show installed Django package info
    echo "Checking for Django installation..."
    pip show django || echo "Django is not installed"
else
    echo "Error: Virtual environment activation failed"
    exit 1
fi

# Wait for the database to be ready
scripts/wait-for-it.sh db:5432 --timeout=30 --strict -- echo "PostgreSQL is up"
echo "Current postgres user: $(whoami)"


# Optionally collect static files
#echo "Collecting static files..."
#python manage.py collectstatic --noinput --ignore=node_modules

# Check for unapplied migrations
MIGRATION_OUTPUT=$(python manage.py showmigrations --plan)

if echo "$MIGRATION_OUTPUT" | awk '/\[ \]/ {exit 0} {exit 1}'; then
    echo "Applying migrations..."
    python manage.py makemigrations || exit 1
    python manage.py migrate || exit 1
    
else
    echo "No migrations to apply."
fi

#echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('blaster', 'newsithempire1@gmail.com', 'droid7')" | python manage.py shell
#    echo "superuser 'blaster' created."

echo "starting django uwsgi on port: $PORT"
#bin/python manage.py runserver 0.0.0.0:$PORT
bin/uwsgi --http=0.0.0.0:$PORT --uid blaster --gid blaster --module=backend.wsgi \
     --master --workers=4 --max-requests=1000 --lazy-apps --need-app \
     --harakiri 65 --vacuum --strict --single-interpreter --die-on-term