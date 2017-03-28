# How to Use Docker Deployment

## Requirements

First make sure Docker and Docker Compose are installed on the machine with:

    $ docker -v
    $ docker-compose -v

If they are missing, follow the instructions on the official website (they are not hard really...):

- [Docker CE Install How-to](https://docs.docker.com/engine/installation/)
- [Docker Compose Install How-to](https://docs.docker.com/compose/install/)


## Brief Explanation

There are several configurations available that enable more or less services
depending on the requirements.

- **docker-compose-prod-full.yml**
    > This is used for production, it has **3 services**, 
    > `WAS`, `File Upload Server` and `Web Server` with `SSL` support.

- **docker-compose-prod-was.yml**
    > This is used in case you want to run only `WAS` in a production environment (*highly discoraged!*).

- **docker-compose-prod-with-hub.yml**
    > Production environment to use together with the [*Web Hub*](https://github.com/sangahco/docker-webapp-hub) service.
    > It has **2 services**, `WAS` and `Web Server`.

- **docker-compose-dev-full.yml**
    > Testing environment where the image have to be built.
    > It has **3 services**,
    > `WAS`, `File Upload Server` and `Web Server`.

- **docker-compose-dev.yml**
    > Testing environment where the image have to be built.
    > This configuration contains only `WAS` instance.

- **docker-compose-jmx.yml**
    > This configuration enable the Java Management Extensions (*JMX*)
    > for remote monitoring of Tomcat instances.

- **docker-compose-certgen**
    > This configuration run the certbot tool to create or update the ssl certificate
    > It require the web server running, to use only for production.


**Important**

> Inside the file `.env` the variable `PROJECT_NAME` have to be changed with the actual project Docker image name. You can find the name on [Jenkins Builder](http://dev.builder.sangah.com) or visiting our [SangAh Registry](https://dev.sangah.com:5044)
> This variable is used as the Docker image name and have to be different from any other projects.

> In case you build manually, check also the variable `PROJECT_ARCHIVE` and make sure the `war` file generated during the building process (`Ant Build`) has the same name.

---

## Prepare for Production

> Here we assume PMIS has been built and an image has been pushed into our registry already 
> (the building process is explained on another documentation).
> The following configuration will take the image `<SANGAH_REGISTRY>/<PROJECT_NAME>` from the registry 
> and will run it as it is without additional build.

First of all download the files from this repository required to run the service:

    $ git clone https://github.com/sangahco/docker-pmis-app.git

Locate the following files inside the folder created:

- `.env`

Before starting the application we need to set the environment and you can choose between two methods:

- Change the settings using the file `.env`, they will be used for this application `only`.
- Use user environment, set these variables at the end of the file `.bashrc`, located inside the user home folder:

    export EDMS_PATH=/edms
    export LOG_PATH=/var/log/pmis
    export APACHE_SSL=1
    export APACHE_SSL_CERT=cert.pem
    export APACHE_SSL_KEY=key.pem
    export APACHE_SSL_CHAIN=chain.pem
    export APACHE_SSL_CERT_PATH=/etc/ssl/app

  This configuration will be global and used amongst all applications on this server.

Some of these properties are required, without them the application can not run, go to the `settings` section to learn more.

---

## Prepare for Testing

Create the `war` file executing the Ant Task `docker-build`, the file will be saved inside the `build/dist/was` folder.

Only after the completion of the previous task, 
from the `build/dist` folder you can run the services.

Remember to use the `dev` mode when running `docker-auto.sh` script!

The application will be available at port `8080` or at the port defined with `HTTP_PORT`.


## Run using **docker-auto** script

**Using the script `docker-auto.sh` is recommended!**

### Show the usage message of this script with:
    $ ./docker-auto.sh --help

### Run the services changing with:

    $ ./docker-auto.sh --prod up

### Stop the application with the following command:

    $ ./docker-auto.sh --prod down

### Observe the application's log with:

    $ ./docker-auto.sh --prod logs

The application will be available at port `80` or `443`.

Change the `mode` whether you want production or testing environment (`--prod`, `--prod-was`, `--dev`, `--full-dev` etc.).


## Run with **docker-compose**

If you need to build before running execute the following commands:

    $ docker-compose -f docker-compose-dev-full.yml pull
    $ docker-compose -f docker-compose-dev-full.yml build --pull

Start the services with:

    $ docker-compose -f docker-compose.prod-full.yml up -d

Stop the service with:

    $ docker-compose -f docker-compose.prod-full.yml down

Show the status:

    $ docker-compose -f docker-compose.prod-full.yml ps

Follow the logs:

    $ docker-compose -f docker-compose.prod-full.yml logs -f --tail 100

*Change the configuration file (\*.yml) depending on what you need*

---

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