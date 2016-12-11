FROM node:6.9.2

RUN curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 0.18.0

ADD package.json yarn.lock /tmp/
RUN /bin/bash -c "source /root/.bashrc && cd /tmp && yarn"
RUN mkdir -p /usr/src/api && cd /usr/src/api && ln -s /tmp/node_modules

RUN mkdir -p /usr/src/api
WORKDIR /usr/src/api
COPY . /usr/src/api

EXPOSE 3000

ENTRYPOINT ["/usr/src/api/entry.sh"]
CMD ["node", "."]