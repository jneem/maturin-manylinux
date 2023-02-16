FROM python:3.7.15-slim-bullseye as builder
RUN apt-get update && apt-get install -y python3 python3-pip libx11-6 libxext6 libxrender1 libglib2.0-0 curl pkg-config
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=/root/.cargo/bin:$PATH
RUN pip3 install -U pip maturin
RUN apt-get install -y \
    libavcodec-dev libavformat-dev libavutil-dev libavfilter-dev \
    libavdevice-dev libclang-dev clang wget

# The packaged version of patchelf is quite old.
RUN wget https://github.com/NixOS/patchelf/releases/download/0.15.0/patchelf-0.15.0-x86_64.tar.gz -O /tmp/patchelf.tar.gz \
    && echo "0b9b93da52f51b3262f783596421a0d1376893d5f865d93f1493da293bd1d4b5 /tmp/patchelf.tar.gz" | sha256sum -c - \
    && tar zxf /tmp/patchelf.tar.gz --strip-components=2 --overwrite -C /bin ./bin/patchelf


COPY . .
ENV RUST_LOG=debug
RUN maturin build

FROM python:3.7.7-slim-buster as runner
COPY --from=builder /target/wheels/maturin_manylinux-0.1.0-cp37-cp37m-manylinux_2_28_x86_64.whl .
RUN apt-get update && apt-get install -y python3 python3-pip libx11-6 libxext6 libxrender1 libglib2.0-0
RUN pip3 install -U pip
RUN pip3 install maturin_manylinux-0.1.0-cp37-cp37m-manylinux_2_28_x86_64.whl
COPY example.py .
RUN python3 example.py