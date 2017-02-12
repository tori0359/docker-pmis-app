# How to Use Docker Deployment

## Brief Explanation

There are three configurations available:

- **docker-compose.yml**
    > This is used for production, it has **4 services**, `WAS`, `SSL`, `File Upload Server` and `Web Server`.

- **docker-compose-dev-full.yml**
    > This is used for testing with **3 services**, `WAS`, `File Upload Server` and `Web Server`.

- **docker-compose-dev.yml**
    > This is used for testing, only **1 service** running `WAS`.


> **Important**
>
> Inside the file `.env` change the variable `PROJECT_NAME` with the actual project name.
> This variable is used as the Docker image name and have to be different from any other projects.

> Check also the variable `PROJECT_ARCHIVE` and make sure the `war` file generated during the building process (`Ant Build`) matches the name.

---

## Production Environment

> Here we assume PMIS has been built and an image has been pushed into our registry already.
> The following configuration will pull the image `<SANGAH_REGISTRY>/<PROJECT_NAME>`
> if this image is not present you will see only errors.

Clone this repository into the server where you will deploy the application:

    $ git clone https://github.com/sangahco/docker-pmis-app.git

Locate the following files inside the folder created:

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

Run the application with the following command and see the magic:

    $ docker-compose up -d

Stop the application with the following command:

    $ docker-compose down

Observe the application's log with:

    $ docker-compose logs -f --tail 100

The application will be available at port `80` or `443`.


## Development Environment

Create the `war` file executing the Ant Task `docker-build`, the file will be saved inside the `build/dist/was` folder.

Only after the completion of the previous task, 
from the `build/dist` folder you should execute the following commands.

Build and Run the application with:

    $ docker-compose -f docker-compose-dev.yml up -d

Stop the application with:

    $ docker-compose -f docker-compose-dev.yml down

Observe the application's log with:

    $ docker-compose -f docker-compose-dev.yml logs -f --tail 100

The application will be available at port `8080` or at the port defined with `HTTP_PORT`.