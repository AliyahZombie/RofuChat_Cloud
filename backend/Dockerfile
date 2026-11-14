FROM rust:1-bookworm AS build
WORKDIR /src
COPY . .
RUN cargo build --release -p rofu-server

FROM debian:bookworm-slim
RUN useradd --system --uid 10001 --create-home rofuchat && mkdir /data && chown rofuchat /data
COPY --from=build /src/target/release/rofu-server /usr/local/bin/rofu-server
USER rofuchat
WORKDIR /data
ENV ROFU_DATABASE=sqlite:///data/rofuchat.db
EXPOSE 7860
ENTRYPOINT ["rofu-server"]
