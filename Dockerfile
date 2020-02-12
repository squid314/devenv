FROM registry.access.redhat.com/ubi8/ubi

ENV pkg=dnf
RUN set -eux ; \
    $pkg config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo ; \
    $pkg makecache -y ; \
    $pkg update -y ; \
    $pkg reinstall -y $($pkg list -y installed | sed -e '/^ /d' -e 's/\..*//' -e '/^filesystem/d') ; \
    $pkg install -y \
        man \
        file \
        sudo \
        git \
        vim \
        zip \
        bzip2 \
        openssl \
        openssh \
        docker-ce-cli \
    ; \
    for i in ex {,r}vi{,ew} ; do \
        for j in vi vim ; do \
            alternatives --install /usr/local/bin/$i $i /usr/bin/$j ${#j} ; \
        done ; \
    done ; \
    $pkg clean all ; \
    rm -rf /var/cache/{yum,dnf}

RUN set -eux ; \
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

RUN set -eux ; \
    curl -svLo /tmp/setup.sh https://a.blmq.us/setup-sh ; \
    bash /tmp/setup.sh docker ; \
    rm /tmp/setup.sh ; \
    ln -s dev/.bin .bin

CMD ["/bin/bash", "-il"]
