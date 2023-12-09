FROM ubuntu:jammy AS build

ARG COMMIT=d78c92968d60d5e500783f68ba4e8de53bb112d5
ARG NAME=libbpf-bootstrap-static-docker

SHELL ["/bin/bash", "-e", "-u", "-o", "pipefail", "-c"]

RUN apt-get update -yq && \
    apt-get install -yq \
	ca-certificates \
	clang \
	curl \
	gcc \
	git \
	libbfd-dev \
	libc-dev \
	libc6-dev-i386 \
	libcap-dev \
	libelf-dev \
	libelf1 \
	make \
	zlib1g-dev \
        llvm && \
	rm -rf /var/cache/apt/archives /var/lib/apt/lists

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /opt/${NAME}/
COPY ${COMMIT}.diff .
RUN git clone https://github.com/libbpf/libbpf-bootstrap

WORKDIR /opt/${NAME}/libbpf-bootstrap/
RUN git checkout ${COMMIT} && \
    git apply ../${COMMIT}.diff && \
    git diff && \
    git submodule update --init --recursive

WORKDIR /opt/${NAME}/libbpf-bootstrap/examples/c
RUN make -j$(nproc) minimal && \
    ./.output/bpftool/bootstrap/bpftool btf dump file /sys/kernel/btf/vmlinux format c > vmlinux.h && \
    make

COPY ./src/. .
COPY ./gen_apps.sh .
RUN ./gen_apps.sh && \
    git diff && \
    make && \
    rm ./gen_apps.sh

RUN mkdir /output && for f in $(find . -maxdepth 1 -executable -type f); do cp "${f}" /output; done

FROM scratch
COPY --from=build /output /bin
