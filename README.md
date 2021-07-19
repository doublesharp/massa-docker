# massa-docker

You will need to have `docker` and `docker-compose` available on your system. Convience scripts in `npm`. 
Clone this repository then use the following commands to run a Massa node or client wallet.

## run node
```
# npm
npm run node

# docker-compose
docker-compose up -d node
```

## run client
```
# script
npm run client

# docker-compose
docker-compose build client
docker-compose run --rm client
```

## build local images
```
# node
npm run node-build

# client
npm run client-build
```
