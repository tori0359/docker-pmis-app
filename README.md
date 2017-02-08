# How to Use Docker Deployment

> Before anything else make sure you change the variable `PROJECT_NAME` with the actual project name.
> This variable is used as the Docker image name and have to be different from any other project.


## Production Environment

Create a folder for the application.

Inside put the following files, located inside the folder `docker`:

- `docker-compose.yml`
- `.env` *(default values)*

Before starting the application change the settings inside the file `.env`
or set these variables at the end of the file `.bashrc`, located inside the user home folder:

	export EDMS_PATH=/edms
	export LOG_PATH=/var/log/pmis
	export APACHE_SSL=1
	export APACHE_SSL_CERT=cert.pem
	export APACHE_SSL_KEY=key.pem
	export APACHE_SSL_CHAIN=chain.pem
	export APACHE_SSL_CERT_PATH=/etc/ssl/app

Important variable to set are:

- `PROJECT_NAME`
- `JAVA_MAX_SIZE`
- `APACHE_SSL`
- `APACHE_SSL_CERT_PATH`

Run the application with the following command:

	$ docker-compose up -d

Stop the application with the following command:

	$ docker-compose down
	
Observe the application's log with:

	$ docker-compose logs -f --tail 100


## Development Environment

Before building the image you need to execute the And Task `docker-build`.

Only after the completion of the previous task, 
from the `build/dist` folder you should execute the following commands.

Build and Run the application with:

	$ docker-compose -f docker-compose-dev.yml build --pull
	$ docker-compose -f docker-compose-dev.yml up -d

Stop the application with:

	$ docker-compose -f docker-compose-dev.yml down
	
Observe the application's log with:

	$ docker-compose -f docker-compose-dev.yml logs -f --tail 100