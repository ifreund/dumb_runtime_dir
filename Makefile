.POSIX:
.SUFFIXES: .c .o .so
.PHONY: all clean install uninstall

PREFIX = /usr/local
LIBDIR = lib
RUNTIME_DIR_PARENT = /run/user
PAM_DIR = $(DESTDIR)$(PREFIX)/$(LIBDIR)/security

CFLAGS = -Os -pipe
PC = pam
PIC_PARAM = -fpic
WARNINGS = -Wall -Wextra -Wpedantic -Wconversion -Werror

PC_C1 != pkg-config --cflags-only-other $(PC) 2>/dev/null || :
PC_C2 != pkg-config --cflags-only-I $(PC) 2>/dev/null || :
PC_L1 != pkg-config --libs-only-other $(PC) 2>/dev/null || :
PC_L2 != pkg-config --libs-only-L --libs-only-l $(PC) 2>/dev/null || echo -l pam

ALL_C1 = $(PIC_PARAM) $(CFLAGS) $(PC_C1) $(WARNINGS) \
	-D 'RUNTIME_DIR_PARENT="$(RUNTIME_DIR_PARENT)"'
ALL_C2 = $(PC_C2)
ALL_L1 = $(LDFLAGS) $(PC_L1)
ALL_L2 = $(LIBS) $(PC_L2)

.c.o:
	exec '$(CC)' -std=c99 -c $(ALL_C1) -o $@ $< $(ALL_C2)

.o.so:
	exec '$(CC)' -shared $(ALL_L1) -o $@ $< $(ALL_L2)

all: pam_dumb_runtime_dir.so

clean:
	find . \( -name \*.o -o -name \*.so \) -exec rm {} \;

install: pam_dumb_runtime_dir.so
	mkdir -p -- $(PAM_DIR)
	cp -- $? $(PAM_DIR)

uninstall: $(PAM_DIR)/pam_dumb_runtime_dir.so
	rm -- $?
