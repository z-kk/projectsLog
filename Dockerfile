# build stage
FROM nimlang/choosenim AS build
RUN choosenim update 2.0.0

RUN nimble update
RUN nimble install docopt
RUN nimble install httpbeast@0.4.2
RUN nimble install jester

ADD . /build
WORKDIR /build
RUN nimble install

# prod stage
FROM debian:stable-slim AS prod

RUN apt-get update && \
    apt-get install -y libsqlite3-0 && \
    apt-get install -y taskwarrior && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY --from=build /build/bin/projectsLog .
ADD src/static public
RUN ln -s data/log.db
