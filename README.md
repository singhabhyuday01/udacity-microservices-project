# Udagram Image Filtering Application

Udagram is a simple cloud application developed alongside the Udacity Cloud Developer Nanodegree. It allows users to register and log into a web client, post photos to the feed, and process photos using an image filtering microservice.

The project is split into two parts:
1. Frontend - Angular web application built with Ionic Framework
2. Backend RESTful API for Users - Node-Express application

The application has a microservice architecture with two backend RESTful web services which sit behind an nginx reverse proxy. The application's repository is integrated with Travis' continuous integration tool which triggers a build when the code is pushed to master branch and create docker images of the <b>four</b> components- frontend application, two backend services, and a reverse proxy and subsequently push these images to Dockerhub. To deploy the application, we have used AWS' Elastic Kubernetes Service (EKS). You can find the files required for deployment in k8-files folder.

> Because of the involved costs with running an EKS cluster and the nodes, the application is currently not deployed.

## Getting Started
> _tip_: it's recommended that you start with getting the backend API running since the frontend web application depends on the API.

### Prerequisite
1. The depends on the Node Package Manager (NPM). You will need to download and install Node from [https://nodejs.com/en/download](https://nodejs.org/en/download/). This will allow you to be able to run `npm` commands.
2. Environment variables will need to be set. These environment variables include database connection details that should not be hard-coded into the application code.

#### Environment Script
A file named `set_env.sh` has been prepared as an optional tool to help you configure these variables on your local development environment.

The config values for environment variables can be set using two ways:<br>
1. If you are deploying this application at local environment, then set these variables in set_env.sh and run it.
2. If you are deploying this application in EKS, then set the values for these variables in k8-files/environment-deployment/*.yaml files.

### 1. Database
Create a PostgreSQL database either locally or on AWS RDS. The database is used to store the application's metadata.

* We will need to use password authentication for this project. This means that a username and password is needed to authenticate and access the database.
* The port number will need to be set as `5432`. This is the typical port that is used by PostgreSQL so it is usually set to this port by default.

Once your database is set up, set the config values for environment variables prefixed with `POSTGRES_` (`POSTGRES_USERNAME`, `POSTGRES_PASSWORD`, `POSTGRES_HOST`, `POSTGRES_DB`).
* If you set up a local database, your `POSTGRES_HOST` is most likely `localhost`
* If you set up an RDS database, your `POSTGRES_HOST` is most likely in the following format: `***.****.us-west-1.rds.amazonaws.com`. You can find this value in the AWS console's RDS dashboard.


### 2. S3
Create an AWS S3 bucket. The S3 bucket is used to store images that are displayed in Udagram. Make sure that the bucket does not have a public access. With that, the bucket will only be accessible inside the VPC.

Set the config values for environment variable `AWS_BUCKET`.

### 3. Backend API- Feed
The API is the application's interface to S3 and the database. This API would read the posts made by the users on the frontend application. It interfaces with the RDS by storing the name of the file that is uploaded by the user. However, it does not upload the file to S3 itself. Instead, it send the client a putObject <b>signed URL</b> for the S3 bucket using which the client can upload the file to the bucket itself. This obviates the need to expose the bucket to the public and at the same time enable the registered users to upload files to it. In case of get operation, this service again sends a getObject signed URL to the user.

This service sits behind a reverse proxy.

* To download all the package dependencies, run the command from the directory `udagram-api-feed/`:
    ```bash
    npm install .
    ```
* To run the application locally, run:
    ```bash
    npm run dev
    ```
* You can visit `http://localhost:8080/api/v0/feed` in your web browser to verify that the application is running. You should see a JSON payload. Feel free to play around with Postman to test the API's.

The deployment and service for this application is in the files `deployment-api-feed.yaml` and `service-api-feed.yaml`.

### 4. Backend API- User
The API is the application's interface to the database. This API is responsible for logging in and registering the users and providing a JWT token to the logged in users which can be used to access the feed API.

This service also sits behind a reverse proxy.

* To download all the package dependencies, run the command from the directory `udagram-api-user/`:
    ```bash
    npm install .
    ```
* To run the application locally, run:
    ```bash
    npm run dev
    ```

The deployment and service for this application is in the files `deployment-api-user.yaml` and `service-api-user.yaml`.

### 5. Frontend App
The frontend app is developed using ionic framework. The application is exposed via nginx proxy. To expose the kubernetes pod publicly, execute the following command-
```
kubectl expose deployment frontend --type=LoadBalancer --name=publicfrontend
```

* To download all the package dependencies, run the command from the directory `udagram-frontend/`:
    ```bash
    npm install .
    ```
* Install Ionic Framework's Command Line tools for us to build and run the application:
    ```bash
    npm install -g ionic
    ```
* Prepare your application by compiling them into static files.
    ```bash
    ionic build
    ```
* Run the application locally using files created from the `ionic build` command.
    ```bash
    ionic serve
    ```
* You can visit `http://localhost:8100` in your web browser to verify that the application is running. You should see a web interface.

The deployment and service for this application is in the files `deployment-frontend.yaml` and `service-frontend.yaml`.
### 6. Reverse proxy
This application will run an Nginx reverse proxy to expose the feed and user services.

The deployment and service for this application is in the files `deployment-reverseproxy.yaml` and `service-reverseproxy.yaml`.

To expose the reverse proxy to public, run the following command:
```
kubectl expose deployment reverseproxy --type=LoadBalancer --name=publicreverseproxy
```

### Set up Horizontal Pod Autoscaler
1. Install metrics-server
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
```

2. To create HPA, run follwing command:
```
kubectl autoscale deployment backend-feed --cpu-percent=50 --min=1 --max=3
```

### Screenshots
The screenshots for the outputs for Pods, Dockerhub images, HPA, Travis pipeline, Pod's logs and Services are in the folder `screenshot`.

## Tips
1. The `.dockerignore` file is included for your convenience to not copy `node_modules`. Copying this over into a Docker container might cause issues if your local environment is a different operating system than the Docker image (ex. Windows or MacOS vs. Linux).
2. `set_env.sh` is really for your backend application. Frontend applications have a different notion of how to store configurations. Configurations for the application endpoints can be configured inside of the `environments/environment.*ts` files.
3. In `set_env.sh`, environment variables are set with `export $VAR=value`. Setting it this way is not permanent; every time you open a new terminal, you will have to run `set_env.sh` to reconfigure your environment variables. To verify if your environment variable is set, you can check the variable with a command like `echo $POSTGRES_USERNAME`.
