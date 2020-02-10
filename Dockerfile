FROM docker.io/library/debian:buster

ENV pkg=apt-get
RUN set -eux ; \
    $pkg update ; \
    $pkg install -y curl gnupg ; \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - ; \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" ; \
    $pkg upgrade -y ; \
    $pkg install -y \
        sudo \
        git-all \
        vim \
        curl \
        zip \
        bzip2 \
        openssl \
        openssh-client \
        docker-ce-cli \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        software-properties-common \
    ; \
    rm -rf /var/lib/apt/lists/*

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
