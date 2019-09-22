# RoasterHammer

## Setup

* Install dependencies: `swift package update`

## Deployment

The application is currently deployed in Heroku.

There is a webhook currently setup for `staging` (staging environment) and `master` (production environment) branches between Heroku and the git repository.

### Setup

* Connect with Heroku: `heroku git:remote -a {app_name}`
* Set stack: `heroku stack:set heroku-16 -a {app_name}`
* Install buildpack: `heroku buildpacks:set https://github.com/vapor-community/heroku-buildpack`
* Create a Procfile for Heroku to build the application

```
 echo "web: Run serve --env production" \
  "--hostname 0.0.0.0 --port \$PORT" > Procfile
```

## Authors

* Thibault Klein