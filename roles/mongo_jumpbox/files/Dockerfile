FROM ubuntu:22.04
RUN apt-get update && apt-get install -y bash gnupg curl wget
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
    && echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && apt-get update \
    && apt-get install -y mongodb-mongosh mongodb-database-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
CMD ["bash"]
