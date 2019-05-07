FROM centos:7.6.1810

ARG plenv_root=/root/.plenv
ARG plenv_version=2.2.0
ARG plenv_perlbuild_version=1.13

ARG perl_version=5.18.2
ARG perl_build_args=-Dusethreads

ARG golang_version=1.10

RUN yum -y install git

RUN yum -y install curl

RUN yum -y install openssl-devel

RUN curl https://dl.google.com/go/go${golang_version}.linux-amd64.tar.gz -o /go${golang_version}.linux-amd64.tar.gz

RUN tar -C /usr/local -xzf /go${golang_version}.linux-amd64.tar.gz

RUN yum -y install "@Development tools"

RUN git clone https://github.com/tokuhirom/plenv.git ${plenv_root}

RUN cd ${plenv_root} && git checkout ${plenv_version}

RUN git clone https://github.com/tokuhirom/Perl-Build.git ${plenv_root}/plugins/perl-build

RUN cd ${plenv_root}/plugins/perl-build && git checkout ${plenv_perlbuild_version}

ENV PATH ${plenv_root}/bin:${plenv_root}/plugins/perl-build/bin:$PATH

RUN plenv install ${perl_version} ${perl_build_args}

RUN plenv global ${perl_version}

RUN plenv rehash

RUN echo 'eval "$(plenv init -)"' >> ~/.bashrc

ENV PATH=/usr/local/go/bin:$PATH

RUN go get github.com/ian-kent/gopan/getpan

RUN go install github.com/ian-kent/gopan/getpan

ENV PATH=/root/go/bin:$PATH

RUN bash -c "PERL_CPANM_OPT='--notest' PLENV_INSTALL_CPANM=' ' ${plenv_root}/bin/plenv install-cpanm"

