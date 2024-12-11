FROM mysql/mysql-server:9.1

ENV TZ=UTC

RUN mkdir /var/log/mysql \
  && chown mysql:mysql $_ \
  && chmod 777 $_
