FROM debian

RUN set -ex ; \
    apt-get update ; \
    apt-get upgrade -y ; \
    apt-get install -y \
        sudo \
        git-all \
        vim \
        curl \
        zip \
        bzip2 \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        software-properties-common \
    ; \
    curl -fsSLo /tmp/gpg https://download.docker.com/linux/debian/gpg ; \
    apt-key add /tmp/gpg ; \
    rm /tmp/gpg ; \
    \
    # dependencies for building git
    apt-get install -y \
        dh-autoreconf \
        libcurl4-gnutls-dev \
        libexpat1-dev \
        gettext \
        libz-dev \
        libssl-dev \
        asciidoc \
        xmlto \
        docbook2x \
        install-info\
    ; \
    git clone --depth 30 https://github.com/git/git.git /tmp/git ; \
    cd /tmp/git ; \
    git checkout $(git log --simplify-by-decoration --decorate --oneline origin/master | sed -n "/tag: v[0-9.]*[),]/{s/.*tag: \\(v[^),]*\\).*/\\1/;p;q}") ; \
    make configure ; \
    ./configure --prefix=/usr ; \
    make all doc info ; \
    make install install-doc install-html install-info ; \
    cd / ; rm -rf /tmp/git ; \
    \
    rm -rf /var/lib/apt/lists/*

RUN set -ex ; \
    groupadd -g 1111 squid ; \
    useradd -ms /bin/bash -u 1111 -g squid squid ; \
    # TODO need this or not?
    echo 'squid   ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers.d/no-passwd-sudo

USER squid
WORKDIR /home/squid

RUN mkdir -p /home/squid/dev && \
    touch /home/squid/{dev,tmp}/.userhold && \
    chown -R squid:squid /home/squid
VOLUME /home/squid/dev

RUN set -ex ; \
    curl -svLo /tmp/setup.sh https://a.blmq.us/setup-sh ; \
    bash /tmp/setup.sh docker ; \
    rm /tmp/setup.sh ; \
    ln -s dev/.bin .bin

CMD ["/bin/bash", "-il"]
