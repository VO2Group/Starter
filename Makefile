# Copy HTML5 application to platforms directories.

SOURCES := www/index.html

PLATFORMS := platforms/android/app/src/main/assets platforms/ios

TARGETS := $(foreach platform, $(PLATFORMS), $(addprefix $(platform)/, $(SOURCES)))

all: $(TARGETS)

$(TARGETS): $(SOURCES)
	cp $^ $@

clean:
	$(RM) $(TARGETS)

.PHONY: all clean
