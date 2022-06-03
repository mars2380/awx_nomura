     
# Locations - set globally to be used across stages
ARG COLLECTION_BASE="/var/lib/awx/vendor/awx_ansible_collections"

# Build container
FROM centos:8 as builder

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER root

# Install build dependencies
RUN dnf -y module enable 'postgresql:12'
RUN dnf -y update && \
    dnf -y install epel-release 'dnf-command(config-manager)' && \
    dnf module -y enable 'postgresql:12' && \
    dnf config-manager --set-enabled powertools && \
    dnf -y install ansible \
    gcc \
    gcc-c++ \
    git-core \
    glibc-langpack-en \
    libcurl-devel \
    libffi-devel \
    libtool-ltdl-devel \
    make \
    nodejs \
    nss \
    openldap-devel \
    patch \
    @postgresql:12 \
    postgresql-devel \
    python3-devel \
    python3-pip \
    python3-psycopg2 \
    python3-setuptools \
    swig \
    unzip \
    xmlsec1-devel \
    xmlsec1-openssl-devel

RUN python3 -m ensurepip && pip3 install "virtualenv < 20"

# Install & build requirements
ADD Makefile /tmp/Makefile
RUN mkdir /tmp/requirements
ADD requirements/requirements_ansible.txt \
    requirements/requirements_ansible_uninstall.txt \
    requirements/requirements_ansible_git.txt \
    requirements/requirements.txt \
    requirements/requirements_tower_uninstall.txt \
    requirements/requirements_git.txt \
    requirements/collections_requirements.yml \
    /tmp/requirements/

RUN cd /tmp && make requirements_awx requirements_ansible_py3
RUN cd /tmp && make requirements_collections


# Use the distro provided npm to bootstrap our required version of node
RUN npm install -g n && n 14.15.1 && dnf remove -y nodejs

# Copy source into builder, build sdist, install it into awx venv
COPY . /tmp/src/
WORKDIR /tmp/src/
RUN make sdist && \
    /var/lib/awx/venv/awx/bin/pip install dist/awx-$(cat VERSION).tar.gz

# Final container(s)
FROM centos:8

ARG COLLECTION_BASE

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

USER root

# Install runtime requirements
RUN dnf -y module enable 'postgresql:12'
RUN dnf -y update && \
    dnf -y install epel-release 'dnf-command(config-manager)' && \
    dnf module -y enable 'postgresql:12' && \
    dnf config-manager --set-enabled powertools && \
    dnf -y install acl \
    ansible \
    bubblewrap \
    git-core \
    git-lfs \
    glibc-langpack-en \
    krb5-workstation \
    libcgroup-tools \
    nginx \
    @postgresql:12 \
    python3-devel \
    python3-libselinux \
    python3-pip \
    python3-psycopg2 \
    python3-setuptools \
    rsync \
    subversion \
    sudo \
    vim-minimal \
    which \
    unzip \
    xmlsec1-openssl && \
    dnf -y install centos-release-stream && dnf -y install "rsyslog >= 8.1911.0" && dnf -y remove centos-release-stream && \
    dnf -y clean all

# Install kubectl
RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.8/bin/linux/amd64/kubectl && \
    chmod a+x /usr/bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Install tini
RUN curl -L -o /usr/bin/tini https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64 && \
    chmod +x /usr/bin/tini

RUN python3 -m ensurepip && pip3 install "virtualenv < 20" supervisor 
RUN rm -rf /root/.cache && rm -rf /tmp/*

# Install OpenShift CLI
RUN cd /usr/local/bin && \
    curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz | \
    tar -xz --strip-components=1 --wildcards --no-anchored 'oc'


# Copy app from builder
COPY --from=builder /var/lib/awx /var/lib/awx

RUN ln -s /var/lib/awx/venv/awx/bin/awx-manage /usr/bin/awx-manage

# Create default awx rsyslog config
ADD installer/roles/image_build/files/rsyslog.conf /var/lib/awx/rsyslog/rsyslog.conf

## File mappings
ADD installer/roles/image_build/files/launch_awx.sh /usr/bin/launch_awx.sh
ADD installer/roles/image_build/files/launch_awx_task.sh /usr/bin/launch_awx_task.sh
ADD installer/roles/image_build/files/settings.py /etc/tower/settings.py
ADD installer/roles/image_build/files/supervisor.conf /etc/supervisord.conf
ADD installer/roles/image_build/files/supervisor_task.conf /etc/supervisord_task.conf
ADD tools/scripts/config-watcher /usr/bin/config-watcher

# Pre-create things we need to access
RUN for dir in \
      /var/lib/awx \
      /var/lib/awx/rsyslog \
      /var/lib/awx/rsyslog/conf.d \
      /var/run/awx-rsyslog \
      /var/log/tower \
      /var/log/nginx \
      /var/lib/postgresql \
      /var/run/supervisor \
      /var/lib/nginx ; \
    do mkdir -m 0775 -p $dir ; chmod g+rw $dir ; chgrp root $dir ; done && \
    for file in \
      /etc/passwd ; \
    do touch $file ; chmod g+rw $file ; chgrp root $file ; done

# Adjust any remaining permissions
RUN chmod u+s /usr/bin/bwrap ; \
    chgrp -R root ${COLLECTION_BASE} ; \
    chmod -R g+rw ${COLLECTION_BASE}


RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

ENV HOME="/var/lib/awx"
ENV PATH="/usr/pgsql-10/bin:${PATH}"

USER 1000
EXPOSE 8052

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD /usr/bin/launch_awx.sh
VOLUME /var/lib/nginx
