FROM quay.io/centos/centos:stream8

ENV pkg=dnf \
    install_config="dnf-command(config-manager)" \
    pkg_config="dnf config-manager" \
    epel="epel-next-release"
RUN set -eux ; \
    $pkg install -y $install_config ; \
    $pkg_config --set-enabled powertools ; \
    $pkg install -y $epel ; \
    $pkg_config --add-repo https://download.docker.com/linux/centos/docker-ce.repo ; \
    $pkg makecache -y ; \
    $pkg update -y ; \
    $pkg reinstall -y $(rpm -qa --qf='%{NAME}\n') ; \
    $pkg install -y \
        man \
        file \
        bash-completion \
        sudo \
        git \
        git-subtree \
        vim \
        zip \
        bzip2 \
        xz \
        rsync \
        openssl \
        openssh \
        docker-ce-cli \
        bind-utils \
        python39 \
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
