# Copy HTML5 application to platforms directories.

all: platforms/android/app/src/main/assets/www/index.html platforms/ios/www/index.html

platforms/android/app/src/main/assets/www/index.html: src/index.html
	cp $^ $@

platforms/ios/www/index.html: src/index.html
	cp $^ $@

clean:
	$(RM) platforms/android/app/src/main/assets/www/index.html
	$(RM) platforms/ios/www/index.html

.PHONY: all clean
