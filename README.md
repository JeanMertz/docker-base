# blendle/base

Provides some easy helpers on top of the extremely lightweight
`gliderlabs/alpine:3.1` image to use when downloading, compiling and verifying
binaries during your own image build process.

This base image clocks in at **7.549 MB** (courtesy of the Alpine image), making
it ideal use as a stepping stone for more complicated images.

## custom helpers

On build, this image will copy all files from your local
`bin/docker/blendle/base/` directory, and make them available as executables
in your container.

## built-in helpers

### bnl-apk-install-build-deps

Installs base packages usually required when building binaries from source:

* `g++=4.8.3-r0`
* `gcc=4.8.3-r0`
* `make=4.1-r0`
* `file=5.22-r0`
* `autoconf=2.69-r0`
* `automake=1.14.1-r0`
* `coreutils=8.23-r0`

### bnl-apl-install-download-deps

Installs base packages used during most download/extract operations:

* `curl=7.39.0-r0`
* `tar=1.28-r0`
* `gpgme=1.5.1-r0`

example:

```docker
RUN bnl-apk-install-download-deps \
    && curl -sSL https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64 | \
       tar zxf - -C /usr/local/bin --strip 1 \
    && apk del download-deps
```

### bnl-download-and-verify

Used to download files and verify the integrity and authenticity of the file
using a cryptographic signature.

usage:

```bash
bnl-download-and-verify PGP_KEY SIGNATURE_FILE_URL [SOURCE_FILE_URL]
```

if `SOURCE_FILE_URL` is omitted, it is assumed to be `SIGNATURE_FILE_URL`
without the final extension.

example:

```docker
RUN bnl-download-and-verify BF357DD4 \
      https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64.asc

# curl -sSL -o gosu-amd64 https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64
# curl -sSL -o gosu-amd64.asc https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64.asc
# bnl-pgp-verify BF357DD4 gosu-amd64.asc gosu-amd64
```

### bnl-make-install-from-source

Combines several make steps into a single command.

usage:

```bash
bnl-make-install-from-source PATH [OPTIONS]
```

example:

```docker
RUN bnl-make-install-from-source nginx-1.7.10 --with-http_ssl_module

# cd nginx-1.7.10
# ./configure --with-http_ssl_module
# make --jobs=8
# make install
# cd ..
# rm -r nginx-1.7.10
```

### bnl-pgp-verify

Verifies file based on provided PGP key (see also `bnl-download-and-verify`).

usage:

```bash
bnl-pgp-verify PGP_KEY SIGNATURE_FILE SOURCE_FILE
```

example:

```docker
RUN bnl-pgp-verify BF357DD4 gosu-amd64.asc gosu-amd64

# gpg-agent --daemon
# gpg --verbose --keyserver pgp.mit.edu --recv-keys BF357DD4
# gpg --verbose --verify gosu-amd64.asc gosu-amd64
# pgrep gpg-agent | xargs kill
# rm gosu-amd64.asc
```
