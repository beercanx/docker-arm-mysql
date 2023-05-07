# MySQL on an ARMv7 docker base

For 5.7 its based on: https://github.com/docker-library/mysql/tree/master/5.7
For 8.0 its based on: https://github.com/docker-library/mysql/tree/611aa464a96f69e5d4d4172b14ca829ded162b42/8.0

## Tags
* `8.0.32`, `8.0`, `8` [(8.0.32/Dockerfile)](https://github.com/beercan1989/docker-arm-mysql/blob/8.0.32/8.0/Dockerfile)
* `5.7.33-1`, `5.7`, `5`, `latest` [(5.7.33+1/Dockerfile)](https://github.com/beercan1989/docker-arm-mysql/blob/5.7.33-1/5.7/Dockerfile)
* `5.7.33` [(5.7.33/Dockerfile)](https://github.com/beercan1989/docker-arm-mysql/blob/5.7.33/Dockerfile)
* `5.7.22` [(5.7.22+1/Dockerfile)](https://github.com/beercan1989/docker-arm-mysql/blob/5.7.22+1/Dockerfile)

## Source
* GitHub: https://github.com/beercan1989/docker-arm-mysql

## Running
```bash
docker run -it \
  -e 'MYSQL_ROOT_PASSWORD=password' \
  -e 'MYSQL_DATABASE=identity' \
  -e 'MYSQL_USER=identity' \
  -e 'MYSQL_PASSWORD=password' \
  -p '3306:3306' \
  --name example_mysql \
  beercan1989/arm-mysql:latest
```

## Running with a volume mounted
Basically it's the same as with the official mysql image.
```bash
docker run -it \
  -e 'MYSQL_ROOT_PASSWORD=password' \
  -e 'MYSQL_DATABASE=identity' \
  -e 'MYSQL_USER=identity' \
  -e 'MYSQL_PASSWORD=password' \
  -p '3306:3306' \
  --name example_mysql \
  -v datadir:/var/lib/mysql \
  beercan1989/arm-mysql:latest
```

## Building, testing, tagging, pushing
### MySQL 5.7
The basic way, while on a RaspberryPi... 
```bash
cd 5.7

docker build -t beercan1989/arm-mysql:latest .

docker run -it \
  -e 'MYSQL_ROOT_PASSWORD=password' \
  -e 'MYSQL_DATABASE=identity' \
  -e 'MYSQL_USER=identity' \
  -e 'MYSQL_PASSWORD=password' \
  -p '3306:3306' \
  --name example_mysql \
  beercan1989/arm-mysql:latest

docker login

docker tag beercan1989/arm-mysql:latest beercan1989/arm-mysql:5
docker tag beercan1989/arm-mysql:latest beercan1989/arm-mysql:5.7
docker tag beercan1989/arm-mysql:latest beercan1989/arm-mysql:5.7.33-1

docker push beercan1989/arm-mysql:latest
docker push beercan1989/arm-mysql:5
docker push beercan1989/arm-mysql:5.7
docker push beercan1989/arm-mysql:5.7.33-1
```

### MySQL 8.0
```bash
cd 8.0

docker build -t beercan1989/arm-mysql:8 .

docker run -it \
  -e 'MYSQL_ROOT_PASSWORD=password' \
  -e 'MYSQL_DATABASE=identity' \
  -e 'MYSQL_USER=identity' \
  -e 'MYSQL_PASSWORD=password' \
  -p '3306:3306' \
  --name example_mysql \
  beercan1989/arm-mysql:8

docker login

docker tag beercan1989/arm-mysql:8 beercan1989/arm-mysql:8.0
docker tag beercan1989/arm-mysql:8 beercan1989/arm-mysql:8.0.32

docker push beercan1989/arm-mysql:8
docker push beercan1989/arm-mysql:8.0
docker push beercan1989/arm-mysql:8.0.32
```