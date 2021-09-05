FROM node:6.14
MAINTAINER Federico Scarpa

COPY .eslintrc.yml .eslintrc.yml
RUN npm install -g mocha@5.2.0 chai@4.3.4 eslint@7.32.0
