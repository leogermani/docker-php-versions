# docker-php-versions

This Docker image is useful to test your project in different PHP versions.

## Setting up

### Clone this repo

```
git clone https://github.com/leogermani/docker-php-versions.git
cd docker-php-versions
```

### Build the image

Build the image passing the `PHP_VERSION` and `COMPOSER_PHAR_URL` arguments. Choose a Composer version that will work with your PHP version.

Below is an example for PHP 5.6

```
docker build -t php56 --build-arg PHP_VERSION=5.6 --build-arg --build-arg COMPOSER_PHAR_URL=https://getcomposer.org/download/1.20.25/composer.phar  .
```

## Using

### Run the Container

```
docker run -d -p 2222:22 -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" php56
```

### Access the container
```
ssh -p 2222 root@localhost
```

(Note: You can still access the container with `docker exec -it contariner /bin/bash`)

### Optionaly mount your project folder

```
docker run -d -p 2222:22 -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -v /home/leo/develop/jetpack:/project  php56
```

## Testing Jetpack packages

I personally use this to test Jetpack packages. 

You can either ssh into the the container and clone the jetpack monorepo, or simply mount the project volume to your local copy of the monorepo.

* SSH into the container
* navigate to the project you want to run tests for (e.g. `cd /project/projects/packages/connection`)
* `composer update` (Note: if you are mounting your local copy, this will override your `vendor` folder)
* `composer run phpunit`