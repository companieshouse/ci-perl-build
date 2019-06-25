# ci-perl-build

Docker configuration for Perl-based CI builds.

## Version Reference

The following list details requirements of the container image for building Perl-based CHS services and should be used for reference when creating new container images:

* Perl 5.18.2 (compiled with `-Dusethreads` flag)
* GNU libc 2.12
* [plenv](https://github.com/tokuhirom/plenv) 2.2.0
* [Perl::Build](https://github.com/tokuhirom/Perl-Build) 1.13
* [GoPAN](https://github.com/companieshouse/gopan/) 0.12

