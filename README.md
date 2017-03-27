# How to Use Docker Deployment

## Brief Explanation

There are Four configurations available:

- **docker-compose.yml**
    > This is used for production, it has **3 services**, 
    > `WAS`, `File Upload Server` and `Web Server` with `SSL` support.

- **docker-compose-dev-full.yml**
    > This is used for testing with **3 services**,
    > `WAS`, `File Upload Server` and `Web Server`.

- **docker-compose-dev.yml**
    > This configuration contains only one `WAS` instance.

- **docker-compose-jmx.yml**
    > This configuration enable the Java Management Extensions 
    > for monitoring Tomcat instance

- **docker-compose-certgen**
    > This configuration run the certbot tool to create or update the ssl certificate
    > It require the web server running, to use only for production.


> **Important**
>
> Inside the file `.env` change the variable `PROJECT_NAME` with the actual project name.
> This variable is used as the Docker image name and have to be different from any other projects.

> Check also the variable `PROJECT_ARCHIVE` and make sure the `war` file generated during the building process (`Ant Build`) matches the name.

---

## Production Environment

> Here we assume PMIS has been built and an image has been pushed into our registry already 
> (the building process is explained on another documentation).
> The following configuration will take the image `<SANGAH_REGISTRY>/<PROJECT_NAME>` from the registry 
> and will run it as it is without additional build.

First of all download the files from this repository required to run the service:

    $ git clone https://github.com/sangahco/docker-pmis-app.git

Locate the following files inside the folder created:

- `docker-compose.yml`
- `.env` *(default values)*

Before starting the application we need to set the environment, you can choose between two methods:

- Change the settings using the file `.env`, they will be used for this application `only`.
- Use Environment Variables, set these variables at the end of the file `.bashrc`, located inside the user home folder:

    export EDMS_PATH=/edms
    export LOG_PATH=/var/log/pmis
    export APACHE_SSL=1
    export APACHE_SSL_CERT=cert.pem
    export APACHE_SSL_KEY=key.pem
    export APACHE_SSL_CHAIN=chain.pem
    export APACHE_SSL_CERT_PATH=/etc/ssl/app

  This configuration will be global and used amongst all applications on this server.

Some of these properties are required, without them the application can not run, go to the `settings` section to learn more.


### Run the application with the following commands and see the magic:

    $ docker-compose pull
    $ docker-compose up -d

`docker-compose pull` will download the latest images of the services before running them.


### Stop the application with the following command:

    $ docker-compose down


### Observe the application's log with:

    $ docker-compose logs -f --tail 100

The application will be available at port `80` or `443`.

---

## Development Environment

Create the `war` file executing the Ant Task `docker-build`, the file will be saved inside the `build/dist/was` folder.

Only after the completion of the previous task, 
from the `build/dist` folder you should execute the following commands.

Build and Run the application with:

    $ docker-compose -f docker-compose-dev.yml build --pull
    $ docker-compose -f docker-compose-dev.yml up -d

Stop the application with:

    $ docker-compose -f docker-compose-dev.yml down

Observe the application's log with:

    $ docker-compose -f docker-compose-dev.yml logs -f --tail 100

The application will be available at port `8080` or at the port defined with `HTTP_PORT`.

You can replace `docker-compose-dev.yml` with `docker-compose-dev-full.yml` to test all services.


## Create SSL Certificate with Certbot (Letsencrypt)

You should take a moment to understand how Letsencrypt (Certbot) works and the folders it use to generate the certificates.
- https://certbot.eff.org/docs/intro.html#understanding-the-client-in-more-depth
- https://certbot.eff.org/docs/intro.html#system-requirements
- https://certbot.eff.org/docs/using.html#where-are-my-certificates


You find a more complete documentation here https://github.com/sangahco/nginx-certbot, please read carefully.

This container run and die as soon the creation or update operation end.

After settings the required variables/properties (`CERTBOT_*`), 
it can be run using the following command:

    $ ./docker-auto.sh --prod --certgen up
    $ ./docker-auto.sh --prod --certgen logs


The best way to use this certgen image is to use the script `update-certs.sh` and schedule the run every week using `crontab`.
Set the required variables inside the script (remove the comment to those variables and change their values)
and add a line to crontab like this (changing the path to the right location of the script):

    00 02 * * 1 /bin/sh ~/update-certs.sh


## Settings Up the Environment

The following settings are available:

| Property/Variable    | Description                                                                                                                                                                            |
|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| PROJECT_NAME(*)      | Project name used for the Docker image and as value for system.project.name property                                                                                                   |
| JAVA_MAX_SIZE(*)     | Java Max Heap Size (It should be at least 2G)                                                                                                                                          |
| MACHINE_HOST(*)      | The full DNS and Port used to reach the tomcat instance  (ex. `203.239.21.121:8080` or `dev.sangah.com:8080`  or if using 80, `dev.sangah.com`)                                        |
| DB_URL(*)            | The full DB url (ex. `jdbc:oracle:thin:@203.239.21.121:1521:AL32UTF8`)                                                                                                                 |
| DB_USERNAME(*)       | The username to access the DB                                                                                                                                                          |
| DB_PASSWORD(*)       | The password to access the DB                                                                                                                                                          |
| HTTP_PORT            | This is the port that you can use to access the service (**development mode only**)                                                                                                    |
| APACHE_SSL           | It enable the SSL access                                                                                                                                                               |
| APACHE_SSL_CERT      | The path to the SSL certificate                                                                                                                                                        |
| APACHE_SSL_KEY       | The path to the SSL key                                                                                                                                                                |
| APACHE_SSL_CHAIN     | The path to the SSL chain certificate                                                                                                                                                  |
| APACHE_SSL_CERT_PATH | This is where the SSL certificate and key are located.                                                                                                                                 |
| CERTBOT_CERTS_PATH   | This is where the SSL certificate have to be generated                                                                                                                                 |
| CERTBOT_HOST         | This is the host (DNS) used for generating the SSL certificates                                                                                                                        |
| CERTBOT_EMAIL        | Email required by the certbot service                                                                                                                                                  |
| JMX_PORT             | The is the port required to connect to the JMX service.                                                                                                                                |
| JMX_HOST             | This is the host that will be used to connect to the JMX service (should be same as `MACHINE_HOST`)                                                                                    |
| HUB_INSTANCE         | This is the alias that will be used by the hub service to connect to this web server instance. This property is valid only if the `docker-compose-with-hub.yml` configuration is used. |

(\*) *These variables are required*