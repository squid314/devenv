FROM quay.io/squid314/devenv:java-21

ENV SCALA_HOME /usr/scala/scala-2
ENV SCALA_VERSION 2.13.13
ENV SCALA_URL https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz
ENV SCALA_SHA256 944b0a06e3146989bc76b72d5f6e8edd09d0fcfd18ab0cb54a0c1f1d1fe80b2d
RUN set -eux ; \
    curl -sfLo /scala.tgz "$SCALA_URL" ; \
    sha256sum /scala.tgz ; \
    echo "$SCALA_SHA256 */scala.tgz" | sha256sum -c - ; \
    mkdir -p "$SCALA_HOME" ; \
    tar --extract --verbose --preserve-order --preserve-permissions --no-same-owner --file /scala.tgz --directory "$SCALA_HOME" --strip-components 1 --exclude '*.bat' ; \
    chmod -R go-w "$SCALA_HOME" ; \
    rm /scala.tgz ; \
    ln -sfT "$SCALA_HOME" /usr/scala/default ; \
    ln -sfT "$SCALA_HOME" /usr/scala/latest ; \
    ln -sf -t /usr/share/man/man1/ "$SCALA_HOME"/man/man1/* ; \
    for bin in "$SCALA_HOME"/bin/* ; do \
        base="$(basename "$bin")" ; \
        [ ! -e "/usr/bin/$base" ] ; \
        alternatives --install "/usr/bin/$base" "$base" "$bin" 20000 ; \
    done ; \
    scala --version

CMD ["/usr/bin/scala"]
