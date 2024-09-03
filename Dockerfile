FROM quay.io/squid314/devenv:java-22

ENV SCALA_HOME /usr/scala/scala-3
ENV SCALA_VERSION 3.5.0
ENV SCALA_URL https://github.com/lampepfl/dotty/releases/download/$SCALA_VERSION/scala3-$SCALA_VERSION.tar.gz
ENV SCALA_SHA256 bacad178623f1940dae7d75c54c75aaf53f14f07ae99803be730a1d7d51a612d
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
