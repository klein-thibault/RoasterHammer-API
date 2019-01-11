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
