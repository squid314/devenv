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
    JAVA_HOME=/usr/java/openjdk-17
ENV JAVA_VERSION=17.0.1 \
    JAVA_URL=https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_linux-x64_bin.tar.gz \
    JAVA_SHA256=1c0a73cbb863aad579b967316bf17673b8f98a9bb938602a140ba2e5c38f880a
RUN set -eux ; \
    curl -sfL -o /openjdk.tgz "$JAVA_URL" ; \
    echo "$JAVA_SHA256 */openjdk.tgz" | sha256sum -c - ; \
    mkdir -p "$JAVA_HOME" ; \
    tar --extract --verbose --preserve-order --preserve-permissions --no-same-owner --file /openjdk.tgz --directory "$JAVA_HOME" --strip-components 1 ; \
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
