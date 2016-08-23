# ...

all: platforms/android/app/src/main/assets/www/index.html \
	platforms/ios/www/index.html

platforms/android/app/src/main/assets/www/index.html: www/index.html
	sed -e 's/www-/android-/g' $^ >$@

platforms/ios/www/index.html: www/index.html
	sed -e 's/www-/ios-/g' $^ >$@

clean: clean-android clean-ios

clean-android:
	rm -f platforms/android/app/src/main/assets/www/index.html

clean-ios:
	rm -f platforms/ios/www/index.html

serve:
	browser-sync start -s www -f '**/*'

.PHONY: all clean serve
