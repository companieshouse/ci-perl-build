FROM centos:centos6.6

ARG plenv_root=/opt/.plenv
ARG plenv_version=2.2.0
ARG plenv_perlbuild_version=1.13

ARG perl_version=5.18.2
ARG perl_build_args=-Dusethreads

ARG gopan_version=0.12
ARG gopan_tag_version=v${gopan_version}

ARG nvm_version=v0.33.11
ARG node_js_version=v10.17.0
ARG grunt_version=v1.2.0

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

# Install distribution-managed package dependencies
RUN yum install -y \
    yum-plugin-ovl \
    which \
    unzip \
    libaio \
    tar \
    curl \
    openssl \
    openssl-devel \
    expat-devel \
    "@Development tools" \
    && yum update -y \
    ca-certificates \
    nss \
    && yum clean all

# Enable Software Collections (SCL) Repository for access to more recent version of git than via yum
RUN yum -y remove git && \
    yum -y install centos-release-scl && \
    yum -y install sclo-git25

ENV PATH "/opt/rh/sclo-git25/root/usr/bin:${PATH}"

# Copy AWS CLI team public key for signature verification
COPY aws-cli-team.pub /root/aws-cli-team.pub

# Retrieve AWS CLI and associated signature file
ADD https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip /root/aws-cli.zip
ADD https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip.sig /root/aws-cli.zip.sig

# Verify signature of AWS CLI package
RUN gpg --import /root/aws-cli-team.pub && \
    gpg --verify /root/aws-cli.zip.sig /root/aws-cli.zip

# Install AWS CLI
RUN unzip /root/aws-cli.zip -d /root && \
    /root/aws/install && \
    rm -rf /root/aws*

# Install Oracle Instant Client and sqlplus as a dependency of DBD::Oracle
RUN tmp_dir=$(mktemp -d /tmp/oracleclient.XXX) && \
    aws2 s3 cp s3://resources.ch.gov.uk/packages/oracle/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm ${tmp_dir} && \
    aws2 s3 cp s3://resources.ch.gov.uk/packages/oracle/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm ${tmp_dir} && \
    aws2 s3 cp s3://resources.ch.gov.uk/packages/oracle/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm ${tmp_dir} && \
    rpm -i ${tmp_dir}/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm && \
    rpm -i ${tmp_dir}/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm && \
    rpm -i ${tmp_dir}/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm && \
    rm -rf ${tmp_dir} && \
    ln -s /usr/local/bin/aws2 /usr/local/bin/aws

ENV ORACLE_HOME "/usr/lib/oracle/11.2/client64"
ENV PATH "/usr/lib/oracle/11.2/client64/bin:${PATH}"
ENV LD_LIBRARY_PATH "/usr/lib/oracle/11.2/client64/lib:${LD_LIBRARY_PATH}"

# Install GoPAN
ADD https://github.com/companieshouse/gopan/releases/download/${gopan_tag_version}/gopan-${gopan_version}-linux_amd64.tar.gz /gopan-${gopan_version}-linux_amd64.tar.gz

RUN tar -C /usr/local/bin -xzf /gopan-${gopan_version}-linux_amd64.tar.gz

RUN rm -f /gopan-${gopan_version}-linux_amd64.tar.gz

# Install Node.js (using NVM) and Grunt (TOFIX: building the container image locally may fail here due to a
# self-signed SSL certificate injected by the corporate proxy when install.sh attempts to clone repositories)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh | bash && \
    \. /root/.nvm/nvm.sh && \
    nvm install ${node_js_version} && \
    npm install -g grunt-cli@${grunt_version}

ENV PATH /root/.nvm/versions/node/${node_js_version}/bin:$PATH

# Install plenv and Perl Build
RUN mkdir -p ${plenv_root} && git clone https://github.com/tokuhirom/plenv.git ${plenv_root}

RUN cd ${plenv_root} && git checkout ${plenv_version}

RUN git clone https://github.com/tokuhirom/Perl-Build.git ${plenv_root}/plugins/perl-build

RUN cd ${plenv_root}/plugins/perl-build && git checkout ${plenv_perlbuild_version}

ENV PATH ${plenv_root}/bin:${plenv_root}/plugins/perl-build/bin:$PATH

# Install Perl
RUN plenv install ${perl_version} ${perl_build_args}

RUN plenv global ${perl_version}

RUN plenv rehash

RUN echo 'eval "$(plenv init -)"' >> ~/.bashrc

RUN mkdir -p /opt/plenv/versions/${perl_version}/bin

RUN bash -c "PERL_CPANM_OPT='--notest' PLENV_INSTALL_CPANM=' ' ${plenv_root}/bin/plenv install-cpanm"

# Set system timezone
RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/Europe/London /etc/localtime

