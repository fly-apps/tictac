# Debugging Notes:
#
#   docker run -it --rm tictac /bin/ash
FROM elixir:1.10-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base npm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=nokey

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
# Need the code files for tailwind purge to work
COPY lib lib
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/tictac ./

ADD entrypoint.sh ./

ENV HOME=/app
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=nokey
ENV PORT=4000
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["bin/tictac", "start"]