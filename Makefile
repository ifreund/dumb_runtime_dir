PREFIX ?= /usr
CC ?= cc
CFLAGS ?= -Os -Wall -Wextra -Wpedantic -Wconversion -Werror

RUNTIME_DIR_PARENT ?= "\"/run/user\""

pam_dumb_runtime_dir.so:
	$(CC) -o $@ pam_dumb_runtime_dir.c -lpam -lpam_misc -shared -fPIC \
	      -std=c99 $(CFLAGS) -D_GNU_SOURCE \
	      -DRUNTIME_DIR_PARENT=$(RUNTIME_DIR_PARENT)

.PHONY: all install uninstall clean

all: pam_dumb_runtime_dir.so

install: pam_dumb_runtime_dir.so
	mkdir -p "$(DESTDIR)$(PREFIX)/lib/security"
	cp pam_dumb_runtime_dir.so "$(DESTDIR)$(PREFIX)/lib/security"

uninstall:
	rm "$(DESTDIR)$(PREFIX)/lib/security/pam_dumb_runtime_dir.so"

clean:
	rm pam_dumb_runtime_dir.so
