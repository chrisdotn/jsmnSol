
FROM node:8.7

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# RUN yarn global add truffle@3.4.x web3@0.18.x truffle-hdwallet-provider mocha@3.5.x mocha-junit-reporter@1.13.x
RUN yarn global add truffle@beta web3@0.18.x mocha@3.5.x mocha-junit-reporter@1.13.x

ENTRYPOINT ["truffle"]
