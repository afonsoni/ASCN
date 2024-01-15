#!/bin/bash

alter_env(){
  echo "Altering .env file..."
  #Edit for a regular expression to match DB_DATABASE in case it has been altered before
  sed -i "s/DB_DATABASE=laravel/DB_DATABASE=$DB_DATABASE/g" .env
  sed -i "s/DB_USERNAME=root/DB_USERNAME=$DB_USERNAME/g" .env
  sed -i "s/DB_PASSWORD=password/DB_PASSWORD=$DB_PASSWORD/g" .env
  echo "Result of .env file..."
  cat /app/laravel.io/.env
  sleep 1
}

alter_env

# Start the MySQL service
start_mysql() {
  echo "Starting the MySQL service..."
  sudo service mysql stop
  sudo usermod -d /var/lib/mysql/ mysql
  sudo service mysql start
}

#Log mysql version
echo "Logging MySQL version..."
mysql --version
#systemctl status mysql

# Start the MySQL service
start_mysql

# Wait for the MySQL service to be ready
while ! nc -z localhost 3306; do sleep 1; done

# # Check if database exists
# if [[ ! -e /var/lib/mysql/laravel ]]; then
#   echo "Database does not exist, creating..."
#   createLaravelDB
# fi

echo "Creating database: $DB_DATABASE..."
mysql -u root -e "CREATE DATABASE $DB_DATABASE;"

echo "Host: $DB_HOST"
echo "Creating user: $DB_USERNAME..."


if [[ $DB_USERNAME = 'root' ]]; then
  mysql -u root -e "ALTER USER 'root'@'$DB_HOST' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';"

else
  mysql -u root -e "CREATE USER '$DB_USERNAME'@'$DB_HOST' IDENTIFIED BY '$DB_PASSWORD';"

fi

echo "Granting all permissions to user..."
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_DATABASE.* TO '$DB_USERNAME'@'$DB_HOST';"
echo "Flushing privileges..."
mysql -u root -e "FLUSH PRIVILEGES;"

echo "Sleeping for 60 seconds before continuing..."
sleep 60

echo "Generating applications key..."
php artisan key:generate

echo "Running migrations..."
php artisan migrate


if [[ $seed_database == "true" && $seeded == "false" ]]; then
  echo "Seeding the database"
  php artisan db:seed
  seeded="true"
fi

#Serve the app
echo "Serving the app..."
php artisan serve --host=0.0.0.0