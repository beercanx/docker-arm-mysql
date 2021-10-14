# MySQL on an ARMv7 docker base

Based on: https://github.com/docker-library/mysql/tree/master/5.7

## Tags
* `5.7.33`, `5.7`, `5`, `latest` [(5.7.33/Dockerfile)](https://github.com/beercan1989/docker-arm-mysql/blob/5.7.33/Dockerfile)
* `5.7.22` [(5.7.22+1/Dockerfile)](https://github.com/beercan1989/docker-arm-mysql/blob/5.7.22+1/Dockerfile)

## Source
* GitHub: https://github.com/beercan1989/docker-arm-mysql

## Running
```
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
Basically its the same as with the official mysql image.
```
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
```
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
docker tag beercan1989/arm-mysql:latest beercan1989/arm-mysql:5.7.33

docker push beercan1989/arm-mysql:latest
docker push beercan1989/arm-mysql:5
docker push beercan1989/arm-mysql:5.7
docker push beercan1989/arm-mysql:5.7.33
```
