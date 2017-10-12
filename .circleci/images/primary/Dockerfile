
FROM node:8.7-slim

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apk add -t .gyp --no-cache git python g++ make
# RUN yarn global add truffle@3.4.x web3@0.18.x truffle-hdwallet-provider mocha@3.5.x mocha-junit-reporter@1.13.x
RUN yarn global add truffle@beta web3@0.18.x mocha@3.5.x mocha-junit-reporter@1.13.x
# RUN npm install -g --force truffle
  #@3.4.x truffle-contract@1.1.x web3@0.18.x mocha@3.5.x mocha-junit-reporter@1.13.x
  # truffle-hdwallet-provider@0.0.x \

RUN apk del .gyp

ENTRYPOINT ["truffle"]
