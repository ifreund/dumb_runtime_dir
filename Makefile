PREFIX = /usr
PAMDIR = $(PREFIX)/lib/security

CC = cc
CFLAGS = -Os -Wall -Wextra -Wpedantic -Wconversion -Werror
PAMFLAGS = $$(pkg-config --cflags --libs pam)

RUNTIME_DIR_PARENT = /run/user

pam_dumb_runtime_dir.so: pam_dumb_runtime_dir.c
	$(CC) -o $@ pam_dumb_runtime_dir.c $(PAMFLAGS) -shared -fPIC -std=c99 $(CFLAGS) \
		'-DRUNTIME_DIR_PARENT="$(RUNTIME_DIR_PARENT)"'

.PHONY: all install uninstall clean

all: pam_dumb_runtime_dir.so

install: pam_dumb_runtime_dir.so
	mkdir -p $(DESTDIR)$(PAMDIR)
	cp -f pam_dumb_runtime_dir.so $(DESTDIR)$(PAMDIR)

uninstall:
	rm -f $(DESTDIR)$(PAMDIR)/pam_dumb_runtime_dir.so

clean:
	rm -f pam_dumb_runtime_dir.so
