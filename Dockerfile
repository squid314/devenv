FROM quay.io/squid314/devenv:java-21

ENV SBT_VERSION=1.9.6 \
    SBT_SHA256=923d7917ccb99a9fd985f4abfd81caacaed42284e67d3f7696cc5239e7c595cb

# sbt and scala setup cloned from https://github.com/sbt/docker-sbt
RUN set -eux ; \
    curl -fsLo /sbt.tgz "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" ; \
    sha256sum /sbt.tgz ; \
    echo "$SBT_SHA256 */sbt.tgz" | sha256sum -c - ; \
    tar -xzf /sbt.tgz -C /usr/share --no-same-owner --exclude '*.bat' ; \
    rm /sbt.tgz ; \
    ln -s /usr/share/sbt/bin/sbt /usr/local/bin/sbt
# Warm sbt cache
RUN set -eux ; \
    sbt sbtVersion ; \
    mkdir /tmp/warmer{,/project} ; \
    cd /tmp/warmer ; \
    echo "sbt.version=${SBT_VERSION}" > project/build.properties ; \
    echo "// force sbt compiler-bridge download" > project/Dependencies.scala ; \
    sbt help ; \
    cd / ; \
    rm -r /tmp/warmer

ENV SCALA_VERSION=3.3.1 \
    SCALA_SHA256=11c0ea0f71c43af0fb1b355dde414bfef01a60c17293675e23a44d025269cd15
RUN set -eux ; \
    case $SCALA_VERSION in \
        "3"*) URL=https://github.com/lampepfl/dotty/releases/download/$SCALA_VERSION/scala3-$SCALA_VERSION.tar.gz SCALA_DIR=/usr/share/scala3-$SCALA_VERSION ;; \
        *)    URL=https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz                    SCALA_DIR=/usr/share/scala-$SCALA_VERSION ;; \
    esac ; \
    curl -fsLo /scala.tgz $URL ; \
    sha256sum /scala.tgz ; \
    echo "$SCALA_SHA256 */scala.tgz" | sha256sum -c - ; \
    tar -xzf /scala.tgz -C /usr/share --no-same-owner --exclude '*.bat' ; \
    mv $SCALA_DIR /usr/share/scala ; \
    ln -s /usr/share/scala/bin/* /usr/local/bin ; \
    case $SCALA_VERSION in \
        "3"*) echo '@main def main = println(s"Scala library version ${dotty.tools.dotc.config.Properties.versionNumberString}")' > test.scala ;; \
        *) echo "println(util.Properties.versionMsg)" > test.scala ;; \
    esac ; \
    scala -nocompdaemon test.scala ; \
    rm test.scala

# TODO example from https://github.com/sbt/docker-sbt uses a non-root user which is probably good. haven't set up a non-root user but it would be good.

# Warm scala cache
RUN set -eux ; \
    mkdir /tmp/warmer{,/project} ; \
    cd /tmp/warmer ; \
    echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt ; \
    echo "sbt.version=${SBT_VERSION}" > project/build.properties ; \
    echo "// force sbt compiler-bridge download" > project/Dependencies.scala ; \
    echo "case object Temp" > Temp.scala ; \
    sbt compile ; \
    cd / ; \
    rm -r /tmp/warmer

# Install git for sbt-native-packager (see https://github.com/sbt/docker-sbt/pull/114)
RUN set -eux ; \
    microdnf install -y git ; \
    microdnf clean all ; \
    rm -rf /var/cache/{yum,dnf}

# TODO create a startup script to detect if there's a project in the workdir. if there is, start sbt; otherwise start scala.
CMD ["/usr/local/bin/scala"]
