FROM ubuntu
MAINTAINER Federico Scarpa

ENV NVM_DIR /.nvm
ENV NODE_VERSION 4.2.4
ENV PATH $HOME/$NVM_DIR:$PATH

RUN apt-get update
RUN apt-get install -y curl git python vim
RUN apt-get autoremove -y

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

RUN ["/bin/bash","-c","source ~/.bashrc"]

RUN . $NVM_DIR/nvm.sh \
	&& nvm install $NODE_VERSION \
	&& nvm use $NODE_VERSION \
	&& nvm alias default $NODE_VERSION \
	&& npm install -g mocha should sinon \
	&& npm install mocha should sinon
