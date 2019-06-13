FROM centos:7.6.1810

ARG plenv_root=/root/.plenv
ARG plenv_version=2.2.0
ARG plenv_perlbuild_version=1.13

ARG perl_version=5.18.2
ARG perl_build_args=-Dusethreads

ARG gopan_version=0.10

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

COPY get-pip.py /get-pip.py

RUN python /get-pip.py
RUN pip install boto
RUN pip install awscli
RUN rm -rf /root/.cache/pip

RUN yum -y install git

RUN yum -y install curl

RUN yum -y install openssl openssl-devel

RUN yum -y install expat-devel

RUN yum -y install "@Development tools"

RUN yum clean all
RUN curl -L https://github.com/companieshouse/gopan/releases/download/${gopan_version}/gopan-${gopan_version}-linux_amd64.tar.gz -o /gopan-${gopan_version}-linux_amd64.tar.gz

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

RUN bash -c "PERL_CPANM_OPT='--notest' PLENV_INSTALL_CPANM=' ' ${plenv_root}/bin/plenv install-cpanm"

