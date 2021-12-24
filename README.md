# dumb_runtime_dir

Creates an `XDG_RUNTIME_DIR` directory on login per the freedesktop.org
base directory spec. Flaunts the spec and never removes it, even after last
logout. This keeps things simple and predictable.

The user is responsible for ensuring that the `RUNTIME_DIR_PARENT` directory
(`/run/user` by default) exists.

## PAM configuration

To enable the pam module, add the following recommended configuration to
`/etc/pam.d/login`:

```
session		optional	pam_dumb_runtime_dir.so
```

See also `pam.conf(5)`.

## Licensing

dumb_runtime_dir is released under the Zero Clause BSD license.
