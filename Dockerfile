FROM docker.io/library/centos:7 AS builder

ENV pkg=yum \
    install_config="yum-utils" \
    pkg_config="yum-config-manager"
RUN set -eux ; \
    sed -ie /^tsflags=nodocs$/s/^/#/ /etc/yum.conf ; \
    $pkg install -y $install_config ; \
    $pkg_config --add-repo https://download.docker.com/linux/centos/docker-ce.repo ; \
    $pkg makecache -y ; \
    $pkg update -y ; \
    $pkg reinstall -y $($pkg list -q -y installed | sed -e 1d -e '/^ /d' -e 's/\..*//') ; \
    $pkg install -y \
        man \
        file \
        bash-completion \
        sudo \
        git-all \
        vim \
        curl \
        zip \
        bzip2 \
        rsync \
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

RUN set -eux ; \
    mkdir /home/squid/{dev,tmp} ; \
    touch /home/squid/{dev,tmp}/.userhold ; \
    curl -svLo /tmp/setup.sh https://a.blmq.us/setup-sh ; \
    bash /tmp/setup.sh docker ; \
    rm /tmp/setup.sh ; \
    ln -s dev/.bin .bin


FROM scratch
COPY --from=builder / /
USER squid
WORKDIR /home/squid
VOLUME /home/squid/dev
VOLUME /home/squid/tmp
CMD ["/bin/bash", "-il"]
