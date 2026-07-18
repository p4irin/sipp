ARG ubuntu_version
ARG sipp_version

FROM ubuntu:${ubuntu_version} as builder

ARG sipp_version

RUN apt-get update && apt-get install -y build-essential cmake apt-utils \
libssl-dev libpcap-dev libsctp-dev libncurses6-dev libgsl-dev && \
apt-get autoremove -y && apt-get clean -y

ADD https://github.com/SIPp/sipp/releases/download/v${sipp_version}/sipp-${sipp_version}.tar.gz /
RUN tar -xzf /sipp-${sipp_version}.tar.gz

WORKDIR /sipp-${sipp_version}
RUN cmake . -DUSE_PCAP=1 -DUSE_GSL=0 -DUSE_SSL=1 -DUSE_SCTP=1
RUN make install

WORKDIR /
RUN rm -rf sipp-${sipp_version}*

FROM ubuntu:${ubuntu_version}
ARG sipp_version
LABEL description="SIPp - a SIP protocol test tool"
LABEL sipp-version="${sipp_version}"
LABEL sipp-github-url="https://github.com/SIPp/sipp"
LABEL sipp-github-url="https://github.com/p4irin/sipp"
LABEL maintainer="https://github.com/p4irin"
LABEL author = "https://github.com/p4irin"
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y && apt-get install -y tzdata openssl libpcap0.8 libsctp1 \
&& apt-get autoremove -y && apt-get clean -y
ENV TZ="Europe/Amsterdam"
WORKDIR /
COPY --from=builder /usr/local/bin/sipp /usr/local/bin/
CMD ["sipp"]
