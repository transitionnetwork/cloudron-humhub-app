# Humhub Cloudron App

This repository contains the Cloudron app package source for Humhub 1.11.1, the flexible open source social media kit.
Repo: https://github.com/humhub/humhub/

## Building

The app package can be built using the [Cloudron command line tooling](https://cloudron.io/references/cli.html) by pulling down the repo and running the following commands:

```
cloudron build
cloudron install
```

* You will need docker installed to build.

Alternatively, after pulling down this repository, run the following command from inside the root of the project:
```
cloudron install --image atridadl/cloudron-humhub-app
```
This will install using my docker container so you wont have to build.

** Note: You will need to use --no-sso for cloudron install if you would like to disable SSO.
