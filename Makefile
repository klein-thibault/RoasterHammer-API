generate-xcode:
	vapor xcode -y

update-xcode:
	vapor update

install:
	swift package update

build:
	swift build

run: build
	swift run

clear: install build

migrate-database-down:
	heroku run Run -- revert --yes --env production

migrate-database-up:
	heroku run Run -- migrate --env production

migrate-database-reset:
	heroku run Run -- revert --all --yes --env production