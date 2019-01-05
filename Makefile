generate-xcode:
	vapor xcode -y

update-xcode:
	vapor update

install:
	swift package install

build:
	swift build

run: build
	swift run

clear: install build
