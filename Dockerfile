FROM php:8.1-fpm

# Cài đặt các phần mở rộng PHP cần thiết
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql gd zip

# Cài đặt Node.js và npm sử dụng nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 18 \
    && nvm use 18 \
    && nvm alias default 18 \
    && npm install -g npm@10.8.1

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Thiết lập thư mục làm việc
WORKDIR /var/www

# Sao chép file vào container
COPY . /var/www

# Chạy composer install để cài đặt các package của Laravel
RUN composer install

# Thiết lập quyền
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage \
    && chmod -R 775 /var/www/bootstrap/cache

# Thiết lập biến môi trường cho Node.js và npm
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 18
RUN echo "source $NVM_DIR/nvm.sh && nvm use $NODE_VERSION" >> ~/.bashrc
