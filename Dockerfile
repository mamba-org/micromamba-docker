FROM alpine:3.18 AS stage1

COPY foo.txt /foo.txt

FROM debian:bookworm-slim AS stage2

COPY --from=stage1 /foo.txt /copy-of-foo.txt
