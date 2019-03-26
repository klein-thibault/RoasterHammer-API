# RoasterHammer

## Deployment

The application is currently deployed in Heroku.

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