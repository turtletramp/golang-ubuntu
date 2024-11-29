FROM ubuntu:16.04
ARG GOLANG_ARCHIVE

RUN apt-get update && apt-get install -y \
    gcc g++ gcc-multilib \
    && rm -rf /var/lib/apt/lists/*

# manually install current go version

ADD ${GOLANG_ARCHIVE} /usr/local
ENV PATH=$PATH:/usr/local/go/bin
RUN go version
