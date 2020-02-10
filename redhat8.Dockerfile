FROM registry.access.redhat.com/ubi8/ubi

RUN set -eux ; \
    dnf makecache -y ; \
    dnf reinstall -y $(dnf list -y installed | sed -e '/^ /d' -e 's/\..*//' -e '/^filesystem/d') ; \
    dnf update -y ; \
    dnf install -y \
        man \
        file \
        sudo \
        git \
        vim \
        zip \
        bzip2 \
        openssl \
        openssh \
    ; \
    for i in ex {,r}vi{,ew} ; do \
        for j in vi vim ; do \
            alternatives --install /usr/local/bin/$i $i /usr/bin/$j ${#j} ; \
        done ; \
    done ; \
    dnf clean all ; \
    rm -rf /var/cache/dnf

# up-to-date java
ENV LANG=en_US.UTF-8 \
    JAVA_HOME=/usr/java/openjdk-13 \
    JAVA_VERSION=13.0.2 \
    JAVA_URL=https://download.java.net/java/GA/jdk13.0.2/d4173c853231432d94f001e99d882ca7/8/GPL/openjdk-13.0.2_linux-x64_bin.tar.gz \
    JAVA_SHA256=acc7a6aabced44e62ec3b83e3b5959df2b1aa6b3d610d58ee45f0c21a7821a71
RUN set -eux ; \
    curl -sfL -o /openjdk.tgz "$JAVA_URL" ; \
    echo "$JAVA_SHA256 */openjdk.tgz" | sha256sum -c - ; \
    mkdir -p "$JAVA_HOME" ; \
    tar --extract --verbose --file /openjdk.tgz --directory "$JAVA_HOME" --strip-components 1 ; \
    rm /openjdk.tgz ; \
    ln -sfT "$JAVA_HOME" /usr/java/default ; \
    ln -sfT "$JAVA_HOME" /usr/java/latest ; \
    for bin in "$JAVA_HOME/bin/"* ; do \
        base="$(basename "$bin")" ; \
        [ ! -e "/usr/bin/$base" ] ; \
        alternatives --install "/usr/bin/$base" "$base" "$bin" 20000 ; \
    done ; \
    java -Xshare:dump ; \
    java --version ; \
    javac --version
ENV \
    SCALA_HOME=/usr/scala/scala \
    SCALA_VERSION=2.13.1 \
    SCALA_URL=https://downloads.lightbend.com/scala/2.13.1/scala-2.13.1.tgz \
    SCALA_SHA256=6918ccc494e34810a7254ad2c4e6f0e1183784c22e7b4801b7dbc8d1994a04db \
    SBT_HOME=/usr/scala/sbt \
    SBT_VERSION=1.3.8 \
    SBT_URL=https://piccolo.link/sbt-1.3.8.tgz \
    SBT_SHA256=27b2ed49758011fefc1bd05e1f4156544d60673e082277186fdd33b6f55d995d
RUN set -eux ; \
    curl -sfLo /scala.tgz "$SCALA_URL" ; \
    echo "$SCALA_SHA256 */scala.tgz" | sha256sum -c - ; \
    mkdir -p "$SCALA_HOME" ; \
    tar --extract --verbose --file /scala.tgz --directory "$SCALA_HOME" --strip-components 1 ; \
    rm /scala.tgz ; \
    ln -sfT "$SCALA_HOME" /usr/scala/default ; \
    ln -sfT "$SCALA_HOME" /usr/scala/latest ; \
    for bin in "$SCALA_HOME/bin/"* ; do \
        base="$(basename "$bin")" ; \
        [ ! -e "/usr/bin/$base" ] ; \
        alternatives --install "/usr/bin/$base" "$base" "$bin" 20000 ; \
    done ; \
    curl -sfLo /sbt.tgz "$SBT_URL" ; \
    echo "$SBT_SHA256 */sbt.tgz" | sha256sum -c - ; \
    mkdir -p "$SBT_HOME" ; \
    tar --extract --verbose --file /sbt.tgz --directory "$SBT_HOME" --strip-components 1 ; \
    rm /sbt.tgz ; \
    ln -sfT "$SBT_HOME" /usr/scala/sbt-default ; \
    ln -sfT "$SBT_HOME" /usr/scala/sbt-latest ; \
    for bin in "$SBT_HOME/bin/"* ; do \
        base="$(basename "$bin")" ; \
        [ ! -e "/usr/bin/$base" ] ; \
        alternatives --install "/usr/bin/$base" "$base" "$bin" 20000 ; \
    done ; \
    scala --version ; \
    sbt --version

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
