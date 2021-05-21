ARG NODE_VERSION=12.18.3
FROM ibmcom/ibmjava:8-sdk as java-base

FROM node:$NODE_VERSION
COPY --from=java-base /opt/ibm/java /opt/ibm/java

ENV TZ='Asia/Shanghai' \
    JAVA_HOME=/opt/ibm/java \
    PATH=/opt/ibm/java/jre/bin:/opt/ibm/java/bin/:$PATH

RUN apt-get update && \
  apt-get install -y curl apt-transport-https maven gradle && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn && \
  rm -rf /var/lib/apt/lists/*
# install scala
RUN wget https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.deb && dpkg -i scala-2.12.8.deb && rm scala-2.12.8.deb

# See : https://github.com/theia-ide/theia-apps/issues/34
RUN adduser --disabled-password --gecos '' theia
RUN chmod g+rw /home && \
    mkdir -p /home/project && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/project;
WORKDIR /home/theia
USER theia

ARG version=latest
ADD $version.package.json ./package.json
ARG GITHUB_TOKEN
RUN yarn --cache-folder ./ycache && rm -rf ./ycache && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build ; \
    yarn theia download:plugins
EXPOSE 3000
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins

USER root

RUN sed -i '$a\deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse' /etc/apt/sources.list && \
    sed -i '$a\deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse' /etc/apt/sources.list

RUN apt-get update
RUN apt-get install language-pack-zh-han* -y
RUN apt install $(check-language-support) -y

RUN sed -i '$a\LANG="zh_CN.UTF-8"' /etc/default/locale && \
    sed -i '$a\LANGUAGE="zh_CN:zh"' /etc/default/locale && \
    sed -i '$a\LC_NUMERIC="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_TIME="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_MONETARY="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_PAPER="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_NAME="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_ADDRESS="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_TELEPHONE="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_MEASUREMENT="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_IDENTIFICATION="zh_CN"' /etc/default/locale && \
    sed -i '$a\LC_ALL="zh_CN.UTF-8dasdaqwdwq"' /etc/default/locale

RUN sed -i '$a\LANG="zh_CN.UTF-8"' /etc/environment && \
    sed -i '$a\LANGUAGE="zh_CN:zh"' /etc/environment && \
    sed -i '$a\LC_NUMERIC="zh_CN"' /etc/environment && \
    sed -i '$a\LC_TIME="zh_CN"' /etc/environment && \
    sed -i '$a\LC_MONETARY="zh_CN"' /etc/environment && \
    sed -i '$a\LC_PAPER="zh_CN"' /etc/environment && \
    sed -i '$a\LC_NAME="zh_CN"' /etc/environment && \
    sed -i '$a\LC_ADDRESS="zh_CN"' /etc/environment && \
    sed -i '$a\LC_TELEPHONE="zh_CN"' /etc/environment && \
    sed -i '$a\LC_MEASUREMENT="zh_CN"' /etc/environment && \
    sed -i '$a\LC_IDENTIFICATION="zh_CN"' /etc/environment && \
    sed -i '$a\LC_ALL="zh_CN.UTF-8dasdaqwdwq"' /etc/environment

RUN sed -i '$a\ANG="zh_CN.UTF-8"' /etc/profile



RUN mkdir -p /home/project/FlinkScalaDemo
COPY FlinkScalaDemo/ /home/project/FlinkScalaDemo
RUN mvn package -f /home/project/FlinkScalaDemo/pom.xml

ENTRYPOINT ["yarn","theia","start","/home/project","--hostname=0.0.0.0"]
