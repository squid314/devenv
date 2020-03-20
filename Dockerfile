FROM quay.io/squid314/devenv:java-14

ENV \
    SCALA_HOME=/usr/scala/scala \
    SCALA_VERSION=2.13.1 \
    SCALA_URL=https://downloads.lightbend.com/scala/2.13.1/scala-2.13.1.tgz \
    SCALA_SHA256=6918ccc494e34810a7254ad2c4e6f0e1183784c22e7b4801b7dbc8d1994a04db
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
    scala --version

CMD ["/usr/bin/scala"]
