FROM quay.io/squid314/devenv:java-19

ENV SCALA_HOME /usr/scala/scala-3
ENV SCALA_VERSION 3.2.2
ENV SCALA_URL https://github.com/lampepfl/dotty/releases/download/$SCALA_VERSION/scala3-$SCALA_VERSION.tar.gz
ENV SCALA_SHA256 b7c5edef42e8cde3e80d71372077a358e4d608461c399cad4432b3fd0c609998
RUN set -eux ; \
    curl -sfLo /scala.tgz "$SCALA_URL" ; \
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
