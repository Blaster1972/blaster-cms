

reset_django() {
    find . -path "*migrations*" -not -regex ".*__init__.py" -a -not -regex ".*migrations" | xargs rm -rf
    python manage.py makemigrations
    psql -c "drop database droid_db;" -U blaster
    psql -c "create database droid_db;" -U blaster
    psql -c "grant all on database droid_db to blaster;" -U blaster
    python manage.py migrate
    echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'badmin@myproject.com', 'pa$$w0rd')" | python manage.py shell
}
