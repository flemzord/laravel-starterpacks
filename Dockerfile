FROM thecodingmachine/php:8.4-v4-apache-node20 AS build
ENV PHP_EXTENSION_PGSQL=1
ENV PHP_EXTENSION_PDO_PGSQL=1
COPY --chown=docker:docker . /var/www/html
WORKDIR /var/www/html
RUN composer install
RUN npm install
RUN npm run build
RUN rm -rf node_modules

ARG INSTALL_CRON=1
FROM thecodingmachine/php:8.4-v4-apache
ENV TZ=Europe/Paris
ENV PHP_EXTENSION_PGSQL=1
ENV PHP_EXTENSION_PDO_PGSQL=1
ENV APACHE_DOCUMENT_ROOT=public/
ENV CRON_USER_1=root
ENV CRON_SCHEDULE_1="* * * * *"
ENV CRON_COMMAND_1="php /var/www/html/artisan schedule:run"
ENV STARTUP_COMMAND_1="php /var/www/html/artisan migrate --force"
COPY --from=build /var/www/html /var/www/html
