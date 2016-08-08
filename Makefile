all: build build/index.html

build:
	mkdir -p build

build/index.html: www/index.html
	cp $^ $@
