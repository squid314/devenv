FROM quay.io/squid314/devenv:java-19

ENV SCALA_HOME /usr/scala/scala-2
ENV SCALA_VERSION 2.13.8
ENV SCALA_URL https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz
ENV SCALA_SHA256 2cb31d8469c651839f0e9c837a1ab06550d031726752f54906be1b9de01314cf
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
