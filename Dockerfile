FROM ubuntu:latest
LABEL authors="canse"

ENTRYPOINT ["top", "-b"]