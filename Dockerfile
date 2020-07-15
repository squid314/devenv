FROM registry.access.redhat.com/ubi8/ubi-minimal

ENV pkg=microdnf
RUN set -eux ; \
    $pkg update -y ; \
    $pkg install -y \
        tar \
        gzip \
    ; \
    $pkg clean all ; \
    rm -rf /var/cache/{yum,dnf}

# up-to-date java
ENV LANG=en_US.UTF-8 \
    JAVA_HOME=/usr/java/openjdk-14
ENV JAVA_VERSION 14.0.2
ENV JAVA_URL https://download.java.net/java/GA/jdk${JAVA_VERSION}/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-${JAVA_VERSION}_linux-x64_bin.tar.gz
ENV JAVA_SHA256 91310200f072045dc6cef2c8c23e7e6387b37c46e9de49623ce0fa461a24623d
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

ARG WORKDIR=/workdir
ENV WORKDIR=$WORKDIR
RUN set -eux ; \
    mkdir -p $WORKDIR ; \
    touch $WORKDIR/.userhold
VOLUME  $WORKDIR
WORKDIR $WORKDIR

CMD ["/usr/bin/jshell"]
