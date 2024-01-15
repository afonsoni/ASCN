# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Disable interactive prompts
ENV DEBIAN_FRONTEND noninteractive

# Set environment variables
ENV MIGRATE true
ENV seed_database false
ENV seeded false

# Install essential packages and Git
RUN apt-get update && apt-get install -y \
    git \
    apt-transport-https \
    software-properties-common

# Clone the Laravel repository
RUN git clone https://github.com/laravelio/laravel.io.git /app/laravel.io

WORKDIR /app/laravel.io

# Create the .env file
RUN cp .env.example .env

# Add the PHP repository to apt
RUN add-apt-repository ppa:ondrej/php && apt-get update

RUN apt install sudo

# Install PHP 8.2 and extensions
RUN apt-get install -y \
    php8.2-cli \
    php8.2-common \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-zip \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-xml \
    php8.2-bcmath \
    systemd \
    netcat \
    composer \
    mysql-server \
    nodejs \
    npm


# Install Vite
RUN npm i vite

# Build
RUN npm run build

# Install Composer Dependencies
RUN composer install

# Expose port 8000
EXPOSE 8000

#Start the app from the shell script
COPY script.sh .
RUN chmod +x script.sh

CMD ./script.sh