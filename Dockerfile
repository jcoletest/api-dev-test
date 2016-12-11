FROM node:6.9.2

# Fetch Yarn
RUN apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg \
    && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install Yarn
RUN apt-get update && apt-get install -y yarn \
    && rm -rf /var/lib/apt/lists/*

ADD package.json yarn.lock /tmp/
RUN cd /tmp && yarn
RUN mkdir -p /usr/src/api && cd /usr/src/api && ln -s /tmp/node_modules

RUN mkdir -p /usr/src/api
WORKDIR /usr/src/api
COPY . /usr/src/api

EXPOSE 3000

ENTRYPOINT ["/usr/src/api/entry.sh"]
CMD ["node", "."]