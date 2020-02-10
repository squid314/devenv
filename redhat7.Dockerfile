FROM registry.access.redhat.com/ubi7/ubi

RUN set -ex ; \
    sed -ie /^tsflags=nodocs$/s/^/#/ /etc/yum.conf ; \
    yum makecache -y ; \
    yum reinstall -y $(yum list -y installed | sed -e '/^ /d' -e 's/\..*//') ; \
    yum update -y ; \
    yum install -y \
        man \
        file \
        sudo \
        git \
        vim \
        curl \
        zip \
        bzip2 \
        docker-client \
        openssl \
        openssh \
    ; \
    for i in ex {,r}vi{,ew} ; do \
        for j in vi vim ; do \
            alternatives --install /usr/local/bin/$i $i /usr/bin/$j ${#j} ; \
        done ; \
    done ; \
    yum clean all

RUN set -ex ; \
    groupadd -g 1111 squid ; \
    useradd -ms /bin/bash -u 1111 -g squid squid ; \
    # TODO need this or not?
    echo 'squid   ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers.d/no-passwd-sudo

USER squid
WORKDIR /home/squid

RUN mkdir -p /home/squid/{dev,tmp} && \
    touch /home/squid/{dev,tmp}/.userhold && \
    chown -R squid:squid /home/squid
VOLUME /home/squid/dev
VOLUME /home/squid/tmp

RUN set -ex ; \
    curl -svLo /tmp/setup.sh https://a.blmq.us/setup-sh ; \
    bash /tmp/setup.sh docker ; \
    rm /tmp/setup.sh ; \
    ln -s dev/.bin .bin

CMD ["/bin/bash", "-il"]
