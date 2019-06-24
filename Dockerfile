FROM centos:centos6.6

ARG plenv_root=/root/.plenv
ARG plenv_version=2.2.0
ARG plenv_perlbuild_version=1.13

ARG perl_version=5.18.2
ARG perl_build_args=-Dusethreads

ARG gopan_version=0.12
ARG gopan_tag_version=v0.12

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

# Enable yum to function correctly with Overlayfs backend
RUN yum install -y yum-plugin-ovl

# Update CA certificates for curl to function with SSL
RUN yum -y update ca-certificates nss curl

# Add EPEL repository to make python-pip available
RUN yum -y install epel-release

# Install pip as a prerequisite to installing awscli
RUN yum -y install python-pip

RUN pip install boto

RUN pip install awscli

# Cleanup pip cache
RUN rm -rf /root/.cache/pip

RUN yum -y install git

RUN yum -y install tar

RUN yum -y install openssl openssl-devel

RUN yum -y install expat-devel

RUN yum -y install "@Development tools"

RUN yum clean all

RUN curl -L https://github.com/companieshouse/gopan/releases/download/${gopan_tag_version}/gopan-${gopan_version}-linux_amd64.tar.gz -o /gopan-${gopan_version}-linux_amd64.tar.gz

RUN tar -C /usr/local/bin -xzf /gopan-${gopan_version}-linux_amd64.tar.gz

RUN rm -f /gopan-${gopan_version}-linux_amd64.tar.gz

RUN git clone https://github.com/tokuhirom/plenv.git ${plenv_root}

RUN cd ${plenv_root} && git checkout ${plenv_version}

RUN git clone https://github.com/tokuhirom/Perl-Build.git ${plenv_root}/plugins/perl-build

RUN cd ${plenv_root}/plugins/perl-build && git checkout ${plenv_perlbuild_version}

ENV PATH ${plenv_root}/bin:${plenv_root}/plugins/perl-build/bin:$PATH

RUN plenv install ${perl_version} ${perl_build_args}

RUN plenv global ${perl_version}

RUN plenv rehash

RUN echo 'eval "$(plenv init -)"' >> ~/.bashrc

RUN mkdir -p /opt/plenv/versions/${perl_version}/bin

RUN ln -s /root/.plenv/shims/perl${perl_version} /opt/plenv/versions/${perl_version}/bin/perl${perl_version}

RUN bash -c "PERL_CPANM_OPT='--notest' PLENV_INSTALL_CPANM=' ' ${plenv_root}/bin/plenv install-cpanm"

# Set system timezone
RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/Europe/London /etc/localtime

