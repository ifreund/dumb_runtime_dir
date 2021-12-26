/**
 * pam_dumb_runtime_dir.c
 *
 * Creates an XDG_RUNTIME_DIR directory on login per the freedesktop.org
 * base directory spec. Flaunts the spec and never removes it, even after
 * last logout. This keeps things simple and predictable.
 *
 * The user is responsible for ensuring that the RUNTIME_DIR_PARENT directory,
 * (/run/user by default) exists and is only writable by root.
 *
 * Copyright 2021 Isaac Freund
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <assert.h>
#include <errno.h>
#include <pwd.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <security/pam_modules.h>

int pam_sm_open_session(pam_handle_t *pamh, int flags,
		int argc, const char **argv) {
	(void)flags;
	(void)argc;
	(void)argv;

	const char *user;
	if (pam_get_user(pamh, &user, NULL) != PAM_SUCCESS) {
		return PAM_SESSION_ERR;
	}

	struct passwd *pw = getpwnam(user);
	if (pw == NULL) {
		return PAM_SESSION_ERR;
	}

	/* The bit size of uid_t will always be larger than the number of
	 * bytes needed to print it. */
	char buffer[sizeof("XDG_RUNTIME_DIR="RUNTIME_DIR_PARENT"/") +
		sizeof(uid_t) * 8];
	int ret = snprintf(buffer, sizeof(buffer),
		"XDG_RUNTIME_DIR="RUNTIME_DIR_PARENT"/%d", pw->pw_uid);
	assert(ret >= 0 && (size_t)ret < sizeof(buffer));
	const char *path = buffer + sizeof("XDG_RUNTIME_DIR=") - 1;

	if (mkdir(path, 0700) < 0) {
		/* It's ok if the directory already exists, in that case we just
		 * ensure the mode is correct before we chown(). */
		if (errno != EEXIST) {
			return PAM_SESSION_ERR;
		}
		if (chmod(path, 0700) < 0) {
			return PAM_SESSION_ERR;
		}
	}

	if (chown(path, pw->pw_uid, pw->pw_gid) < 0) {
		return PAM_SESSION_ERR;
	}

	if (pam_putenv(pamh, buffer) != PAM_SUCCESS) {
		return PAM_SESSION_ERR;
	}

	return PAM_SUCCESS;
}
