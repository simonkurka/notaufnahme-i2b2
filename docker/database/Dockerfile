FROM postgres:12
COPY ./sql/i2b2_postgres_init.sql /sql.d/00_i2b2_init.sql
COPY ./sql/i2b2_db.sql /sql.d/01_i2b2_data.sql
COPY ./sql/i2b2_postgres_drop.sql /sql.d/i2b2_drop.sql
RUN cat /sql.d/00_i2b2_init.sql >>/docker-entrypoint-initdb.d/init.sql
RUN cat /sql.d/01_i2b2_data.sql >>/docker-entrypoint-initdb.d/init.sql
ENV POSTGRES_PASSWORD=postgres

