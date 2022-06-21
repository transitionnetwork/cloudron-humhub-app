# Humhub Cloudron App

This repository contains the Cloudron app package source for Humhub 1.11.1, the flexible open source social media kit.
Repo: https://github.com/humhub/humhub/

## Change source repository
At the top of the Dockerfile there are two environment variables:
- ENV HUMHUB_VERSION=1.11.2
- ENV REPO_URL=https://github.com/humhub/humhub/archive/refs/tags/v${VERSION}.tar.gz

You can either update the version (which is the tag ID of the latest release) or the repository URL itself. Please note that the repository URL is the URL of a tar.gz file containing the source code. You can grab this straight from the master or main branch or from a specific tag.

example: https://github.com/transitionnetwork/humhub/archive/refs/heads/transition-network.tar.gz

## Installiing the Cloudron CLI
```
sudo npm install -g cloudron
```

## Logging into the cloudron CLI
```
cloudron login my.example.com
```

## Building
* You will need docker installed to build.
```
cloudron build
```

## Installiing
The following command will install the app using the container you built in the previous step:
```
cloudron install
```

Alternatively, after pulling down this repository, run the following command from inside the root of the project:
```
cloudron install --image atridadl/cloudron-humhub-app
```
This will install using my docker container so you wont have to build.

** Note: You will need to use --no-sso for cloudron install if you would like to disable SSO.
