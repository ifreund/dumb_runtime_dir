PREFIX ?= /usr
CC ?= cc
CFLAGS ?= -Os -Wall -Wextra -Wpedantic -Wconversion -Werror

RUNTIME_DIR_PARENT ?= "\"/run/user\""

pam_dumb_runtime_dir.so:
	$(CC) -o $@ pam_dumb_runtime_dir.c -lpam -shared -fPIC -std=c99 $(CFLAGS) \
		-DRUNTIME_DIR_PARENT=$(RUNTIME_DIR_PARENT)

.PHONY: all install uninstall clean

all: pam_dumb_runtime_dir.so

install: pam_dumb_runtime_dir.so
	mkdir -p "$(DESTDIR)$(PREFIX)/lib/security"
	cp pam_dumb_runtime_dir.so "$(DESTDIR)$(PREFIX)/lib/security"

uninstall:
	rm pam_dumb_runtime_dir.so "$(DESTDIR)$(PREFIX)/lib/security"

clean:
	rm pam_dumb_runtime_dir.so
