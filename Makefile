# ...

all: platforms/android/app/src/main/assets/www/index.html \
     platforms/ios/www/index.html

clean: clean-android clean-ios

platforms/android/app/src/main/assets/www/index.html: www/index.html
	cp $^ $@

platforms/ios/www/index.html: www/index.html
	cp $^ $@

clean-android:
	$(RM) platforms/android/app/src/main/assets/www/index.html

clean-ios:
	$(RM) platforms/ios/www/index.html
