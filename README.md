# ci-perl-build

A Docker configuration for Perl-based CI builds suitable for building both CHS services and dependency packages (i.e. prepackaged `.zip` files) for those services.

## Build Tools

The following list details the build tools required by all CHS Perl-based services which will be installed in the container image:

* Perl 5.18.2 (compiled from source with the `-Dusethreads` flag)
* GNU libc 2.12
* [plenv](https://github.com/tokuhirom/plenv) 2.2.0
* [Perl::Build](https://github.com/tokuhirom/Perl-Build) 1.13
* [GoPAN](https://github.com/companieshouse/gopan/) 0.12

## Dependencies

The following list details the distribution-managed packages installed in the container image and the reason for their inclusion:

| Name                  | Purpose                                                                                                                 |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------|
| `yum-plugin-ovl`      | Required to allow the distribution package manager `yum` to function correctly with the Docker OverlayFS storage driver |
| `libaio`              | Required dependency of Oracle Instant Client                                                                            |
| `tar`, `unzip`        | Required for handling `.zip` and `.tar.gz` files during project builds                                                  |
| `curl`                | Required for installing NVM                                                                                             |
| `expat-devel`, `@Development tools` | Required when building Perl services in the resulting image                                               |
| `openssl`, `openssl-devel`, `ca-certificates`, `nss` | SSL libraries used by multiple tools in the image; CA certificate updates are required to support the latest SSL certificates used by some of the domains accessed during the image build |
| `sclo-git25` via Software Collections (SCL) Repository | Used to install a more recent version of Git than available via `yum`; required by NVM install script to ensure Git supports latest CA certificates for SSL enabled domains (i.e. GitHub) |

In addition to the distribution-managed packages detailed above, the following tools are also installed:

| Name                       | Version      | Purpose                                                                                           |
|----------------------------|--------------|---------------------------------------------------------------------------------------------------|
| AWS CLI                    | `2.0.0dev2`  | Used to retrieve non distribution-managed packages from the S3 resources bucket under our control |
| Oracle Instant Client      | `11.2.0.4.0` | Required dependency of the `DBD::Oracle` Perl module used by [chs-backend](https://github.com/companieshouse/chs-backend); comprises three `.rpm` files:<br>- `oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm`<br>- `oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm`<br>- `oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm`                        |
| Node Version Manager (NVM) | `v0.33.11`   | Required to install Node.js (see below)                                                           |
| Node.js                    | `v10.17.0`   | Requirement of [developer.ch.gov.uk](https://github.com/companieshouse/developer.ch.gov.uk) service build |
| Grunt                      | `v1.2.0`     | Requirement of [developer.ch.gov.uk](https://github.com/companieshouse/developer.ch.gov.uk) service build |

