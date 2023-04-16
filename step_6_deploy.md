# Deploy

## Introduction

### Abstract

Why deploy our model in production? Why deploy it on the Cloud?

Deploying our service in production means making our application available to as many people as possible by
ensuring our customers a technical environment that is:

- stable: our webservice responds to our customers in a consistent way, the new versions of our service
  are validated and tested before being deployed on our production environment (updates)
- robust: production must respond as quickly as possible, as best as possible, while supporting the load that we
  imposes on it (ability to respond to as many customers as possible at the same time). Production must be scaled.
- secure

In the lifecycle of a project, our application will be executed on several types of environment:

![environments](documentation/production/3%20-%20containers/environments.png)

- local: Your own development environment, your local machine or your Codespace. Allows you to validate your developments directly.
- development: first environment on which you deploy your service. This environment will be updated
  very often and allows you to validate that technically, your new service version runs well on a technical environment
  consistent with your production. This environment is generally less powerful than the production environment
- preproduction (stagging): The final stage before production, this environment is traditionally shaped like production.
  Allows you to validate the good performance of your service in an environment that is near of your production. 
  Often used by Q&A or Product Owners to confirm definitively that the service meets its requirements.
- production

These environments allow us to secure, test, validate our application before deploying it and impacting our users

BTW, what is a Cloud? For what purposes?

![usual platform](documentation/production/3%20-%20containers/usual%20platform.png)

![focus on prem](documentation/production/3%20-%20containers/focus%20on%20prem.png)


### In the Cloud, different kinds of platforms

What are the most famous Cloud Providers in the World?

Offers? Services? Pricing?

What kinds of platforms?

- **IaaS**: Infrastructure As A Service
- **PaaS**: Platform As A Service
- **SaaS**: Service As A Service
- **CaaS**: Container As A Service

What do they mean? What are the differences between them?

![with cloud providers](documentation/production/3%20-%20containers/with%20cloud%20providers.png)

CaaS means that we will use containers. But what are they?

## 3 - Containers with Docker 

### a - What is a container? What are the differences with virtualization? 

![differences](documentation/production/3%20-%20containers/VM%20vs%20containers.png)

### b - Why we should use them for ML? 

![artifacts](documentation/production/3%20-%20containers/dev%20artifact.png)

Few arguments:
- They are lighter
- This solution is more scalable
- This solution is more flexible (we choose the python version for example)
- We can install libraries on the host os easily 
- You can run your artifact locally as it could run remotely, in the Cloud

### c - What is Docker? How does it work?

Docker is container software. It is one of the most used in the market. Containers runs in the Docker daemon.
A command line interface allows to interact with the Docker daemon.

A container relies on an image. An image is created with a Dockerfile file. This image is like a template.

This is a sum up about the Docker Engine:

![docker sum up](documentation/production/3%20-%20containers/docker%20sum%20up.png)

An image uses instructions to create the layers of the template.

When you build an image, you can push it to a container registry. There are a lot of different container registries in the market. The most popular
is Docker Hub : https://hub.docker.com/

Now, let's play with docker!

First, we will launch a Debian system onto it. To do so, we search it on google. We can reach a page from Docker Hub: https://hub.docker.com/_/debian

We will use the tag bullseye. You can find all the tags from the Tags section of this page.

```bash
docker run -it debian:bullseye bash
```

This command will pull the image from the docker registry, create a container from this image and launch a bash prompt on it.

As you can see, we are currently root :

![running debian](documentation/production/3%20-%20containers/playing%20with%20docker/running%20debian.png)

As you can see, the container you are currently running is a rudimentary debian. From your prompt if you want to launch the python interpreter. it will not work!

![python not working](documentation/production/3%20-%20containers/playing%20with%20docker/python%20not%20working.png)

It is because this system does not have python installed on it. Let's try to execute a script in python.

```bash
apt update
apt install python
apt install vim

mkdir /opt/app-root
cd /opt/app-root
touch my_script.py

vim my_script.py
```

In this script, write this code:

```python
import platform 
print("Coucou ! On tourne sur " + platform.platform())
```

Now we can launch this script from the python interpreter:

```bash
python my_script.py
```

Now we quit the command prompt of our container:

```bash
exit
```

By quitting the prompt, the container will shut down. To see it, use this command:

```bash
docker ps -a
```

ps list all the containers the active containers. You can add the option -a to list all of them, including the closed ones.

Now let's clean our workspace by deleting this closed container:

```bash
docker rm <id of the container>
```

Note that the image docker pulled from the registry is still in cache in your local docker engine. To list them, you can use the command:

```bash
docker images
```

To delete properly the image, you can use the command:


```bash
docker rmi <id of the image>
```

As you can see, it can be difficult to create a ready to use runtime environment if we had to launch some linux commands to install python, push our code on it ect.

But we can create our own images !!!

By writing a Dockerfile, we will use some instructions to build our image. Now, let's write our first Dockerfile.

### d - Writing our first Dockerfile

In this section, we will try to make the same thing we have done in the previous playground, but directly from a custome Docker image.

First, we have to create this file: Dockerfile

We will use an official python image from Docker as the base of our image. And we will build some custom layers upon it.

If we navigate in the Docker hub website, we can find this page : https://hub.docker.com/_/python

It gives us all the python image created by the community. One of them is a bullseye image with python already installed on it.

We will begin our construction with this image. To do so, in our Dockerfile, we add this instruction:

```dockerfile
FROM python:3.11.2-bullseye
```

This instruction tells we are constructing our image FROM the python:3.11.2-bullseye as a base. 

Okay! That's a good start! Now let's build this image and create a container from it!

```bash
docker build -t mlopspython/first-image .

docker run -it mlopspython/first-image
```

When you launch the docker run command, as you can see, it opens the python interpreter within our container. It is because the image is constructed like this.

If you look at the end of the Dockerfile of this image (https://github.com/docker-library/python/blob/2bcce464bea3a9c7449a2fe217bf4c24e38e0a47/3.11/bullseye/Dockerfile), a "python3" command is launched.

To do so, the CMD instruction is used. You can dig on this subject by consulting this page : https://medium.com/ci-cd-devops/dockerfile-run-vs-cmd-vs-entrypoint-ae0d32ffe2b4

As you should see, a CMD final instruction can be overriden. So if we launch our container with this command:

```bash
docker run -it mlopspython/first-image bash
```

It will launch the container and gives us a root command prompt like before! Exit first your container with the exit() python instruction and let's give a try!

Ok! Now, we want to create our /opt/app-root directory and our python script.

In our Dockerfile:

```dockerfile
FROM python:3.11.2-bullseye

RUN mkdir /opt/app-root

WORKDIR /opt/app-root

RUN echo "import platform\nprint(\"Coucou ! On tourne sur \" + platform.platform())" > myscript.py
```

Now, let's build our image and run our container again!

```bash
docker build -t mlopspython/first-image .

docker run -it mlopspython/first-image bash
```

As you can see, this time, the python image has not been downloaded again. It is because the image is record in the local Docker cache!

![not download again](documentation/production/3%20-%20containers/playing%20with%20docker/not%20downloading%20image%20again.png)

Now, from your container, if you launch this command:

```bash
python /opt/app-root/myscript.py
```

Now, we exit the container and we will try to go further.

```bash
exit
```

But first, clean correctly your dead containers.

Now we want to tell to our image to execute the script by itself and print the result, without running and opening the container by ourself.

To do so, we will use the instruction ENTRYPOINT:

```dockerfile
FROM python:3.11.2-bullseye

RUN mkdir /opt/app-root

WORKDIR /opt/app-root

RUN echo "import platform\nprint(\"Coucou ! On tourne sur \" + platform.platform())" > myscript.py

ENTRYPOINT ["python", "myscript.py"]
```

Now, let's build the image and run it!

```bash
docker build -t mlopspython/first-image .
```

As you can see, when you run this build, the lines which already exists are cached and not ran again!

![not caching again](documentation/production/3%20-%20containers/playing%20with%20docker/precedence%20is%20cached.png)

```bash
docker run mlopspython/first-image
```

Note that this time, we are running the container without the -it option. It is because we do not want to open a prompt in the container, but just let it execute its code.

Normally, you should see somthing like this:

![running](documentation/production/3%20-%20containers/playing%20with%20docker/running.png)

Now, it is time to construct our docker image which will contain and run our API!

### e - The Dockerfile of our WebService

But before writing our Dockerfile, lets focus on some new instructions. You can find these definitions come from the Docker reference documentation : https://docs.docker.com/engine/reference/builder/

- **ENV**: Set an environment variable.  
- **WORKDIR**: The WORKDIR instruction sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that follow it in the Dockerfile.
- **COPY**: The COPY instruction copies new files or directories from <src> and adds them to the filesystem of the container at the path <dest>.
- **EXPOSE**: The EXPOSE instruction informs Docker that the container listens on the specified network ports at runtime.
- **ENTRYPOINT**: An ENTRYPOINT allows you to configure a container that will run as an executable.

Now, let's try to create your Docker image. You can look at the Makefile to know how to build your project with pip.

Do not forget to EXPOSE the port of your Webservice (kindly reminder, we set it to 8080), and to set a final ENTRYPOINT.

This is a proposition:

```dockerfile
FROM python:3.11.2-bullseye

ENV APP_ROOT=/opt/app-root

WORKDIR ${APP_ROOT}

COPY boot.py ./boot.py
COPY packages ./packages
COPY production ./production

RUN python -m pip install --upgrade pip
RUN python -m pip install --upgrade setuptools wheel
RUN pip install -e packages/inference

WORKDIR ${APP_ROOT}/packages/inference

RUN python setup.py sdist bdist_wheel

WORKDIR ${APP_ROOT}

RUN cp ./packages/inference/dist/*.whl production/api/packages
RUN pip install -e packages/extraction

WORKDIR ${APP_ROOT}/packages/extraction

RUN python setup.py sdist bdist_wheel

WORKDIR ${APP_ROOT}

RUN cp ./packages/extraction/dist/*.whl production/api/packages
RUN pip install -r production/api/requirements.txt

EXPOSE 8080

ENTRYPOINT ["python3", "boot.py"]
```

Now, we build and run our image:

```bash
docker build -t mlops_python_2022_2023:1.0.0 .

docker run -d -p 8080:8080 -e OAUTH2_ISSUER="your issuer" -e OAUTH2_AUDIENCE="your audience" -e OAUTH2_JWKS_URI="the uri" mlops_python_2022_2023:1.0.0
```

Note the option -d in our docker run command. It is for "detached". It will run the container in detached mode.

-p option allows us to bind the 8080 port of the container to the 8080 port of the host.

-e Allows you to add some environment variables. They are used here to configure your oAuth2 token validator.

This is a complete example : 

```bash
docker run -d -p 8080:8080 -e OAUTH2_ISSUER="https://dev-ujjk4qhv7rn48y6w.eu.auth0.com/" -e OAUTH2_AUDIENCE="https://gthomas-cats-dogs.com" -e OAUTH2_JWKS_URI=".well-known/jwks.json" mlops_python_2022_2023:1.0.0
```

Now, let's try our Service from Postman!

Do not forget to change the visibility of the 8080 port from Codespace to Public.

Generate an oAuth2 token from Auth0.

And now you can test your API : 

![test](documentation/production/3%20-%20containers/playing%20with%20docker/testing%20container%20from%20postman.png)

To finish this chapter, we need to publish our image to a registry.

### f - Push the image to registry

As registry, we will use Quay, from RedHat. First, we need to create an account on the website https://developers.redhat.com/.

Then, we have to create a Public repository on Quay to push our image on it. To do so, log yourself on quay.io and click to Repositories and on Create New Repository:

![create repo](documentation/production/3%20-%20containers/quay/create%20a%20repository.png)

Now we create a new public repository named mlops_python_2022_2023:

![create our public repo](documentation/production/3%20-%20containers/quay/create%20our%20public%20repository.png)

As you can see, it creates an empty repository named quay.io/yourid/mlops_python_2022_2023:

![empty repo](documentation/production/3%20-%20containers/quay/empty%20repo.png)

Now we will push our image to this new repository.

First, we generate a token to log ourself in from docker to quay. To do so, we will use a Robot Account. We have to create it.

![password](documentation/production/3%20-%20containers/quay/password.png)

As the website say, a robot account is used for ci/cd pipelines. We will use it in a github action later !

We will name this robot mlopspython_2022_2023_robot:

![create robot](documentation/production/3%20-%20containers/quay/create%20robot.png)

Now we add Write permissions to this robot (we do not need read permissions, we will only push images and not pull with this account).

![add permissions](documentation/production/3%20-%20containers/quay/add%20permissions.png)

Now, get your credentials in order to log docker in.

![get credentials](documentation/production/3%20-%20containers/quay/get%20credentials.png)

You can click on docker login to generate a docker command that you can copy and paste in your terminal.

![docker login](documentation/production/3%20-%20containers/quay/docker%20login.png)

Now, your docker client is connected to quay with your robot account

We have to create new tags of our image : 

```bash
docker tag <id of your image> quay.io/yourquayaccount/mlops_python_2022_2023:1.0.0
docker tag <id of your image> quay.io/yourquayaccount/mlops_python_2022_2023:latest
```

And now, we push !

```bash
docker push quay.io/gthomas59800/mlops_python_2022_2023:1.0.0
docker push quay.io/gthomas59800/mlops_python_2022_2023:latest
```

You should see these tags in your repository:

![images pushed](documentation/production/3%20-%20containers/quay/images%20are%20pushed.png)

But it is not finished. We will not push our images with our hands ! You asked for them, we will use github actions!!!! Hurray !

### g - Build automatically with github actions

We will create a github action to go build and push automatically our new images!

To do so, we have to commit our modifications. To do so, we will create a new branch first:

```bash
git checkout -b api/github_action
git add .
git commit -m "feat: Push our dockerfile in a new branch"
git push --set-upstream origin api/github_action
```

Note that your Codespace has now switched of branch. It is working on api/github_action now!

In the folder .github/workflows, create a new file: quay-deploy.yml

In this file, add these lines:

```yaml
name: MLOps 2022/2023 Docker Images CI
on:
  push:
    branches: [ "api/github_action" ]
jobs:
  build_api:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          registry: quay.io
          username: ${{ secrets.QUAY_USER }}
          password: ${{ secrets.QUAY_PWD }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v2
        with:
          context: .
          push: true
          tags:  quay.io/yourquayaccount/mlops_python_2022_2023:1.0.0,quay.io/yourquayaccount/mlops_python_2022_2023:latest
```

Create the two secrets QUAY_USER and QUAY_PWD in your github project. Use the credentials of your robot account. 
And now, you should have a github action which will build your image for each push on your branch, and then push it to quay.


![add secrets in github](documentation/production/3%20-%20containers/quay/add%20secrets%20in%20github.png)

You have to push quay-deploy.yml in your new branch. To do so, you can run these commands in your terminal:

```bash
git add .
git commit -m "feat: Add a new github action to build our image and push it in quay.io"
git push 
```

And now, you should see a github action in action !!!

![github action](documentation/production/3%20-%20containers/quay/github%20action%20in%20action.png)

This chapter comes to its end! Now we will deploy this image in the Cloud!!!
