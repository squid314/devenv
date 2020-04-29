FROM quay.io/squid314/devenv:java-14

ENV SCALA_HOME /usr/scala/scala
ENV SCALA_VERSION 2.13.3
ENV SCALA_URL https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz
ENV SCALA_SHA256 c9f3731bccf26cf39ac5413172fb41646cb19f63b8a2bb75f38e89675ce2697f
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
