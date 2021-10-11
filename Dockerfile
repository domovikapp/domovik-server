ARG MIX_ENV="prod"

# FROM hexpm/elixir:1.11.2-erlang-23.1.2-alpine-3.12.1 as build
FROM hexpm/elixir:1.12.3-erlang-24.1.2-alpine-3.14.2 as build

# install build dependencies
RUN apk add --no-cache build-base git python3 curl npm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/$MIX_ENV.exs config/
RUN mix deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error


# note: if your project uses a tool like https://purgecss.com/,
# which customizes asset compilation based on what it finds in
# your Elixir templates, you will need to move the asset compilation
# step down so that `lib` is available.
COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build the release
COPY lib lib
RUN mix compile
# changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM alpine:3.12.1 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ARG MIX_ENV
ENV USER="elixir"

WORKDIR "/home/${USER}/app"
# Creates an unprivileged user to be used exclusively to run the Phoenix app
RUN \
  addgroup \
   -g 1000 \
   -S "${USER}" \
  && adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "/home/${USER}" \
   -D "${USER}" \
  && su "${USER}"

# Everything from this line onwards will run in the context of the unprivileged user.
USER "${USER}"

COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/domovik ./

ENTRYPOINT ["bin/domovik"]

# Usage:
#  * build: sudo docker image build -t domovikapp/domovik .
#  * shell: sudo docker container run --rm -it --entrypoint "" -p 127.0.0.1:4000:4000 domovikapp/domovik sh
#  * run:   sudo docker container run --rm -it -p 127.0.0.1:4000:4000 --name domovik domovikapp/domovik  -e "DATABASE_URL=ecto://USER:PASSWORD@HOST/DATABASE" -e"SECRET_KEY_BASE=xxx"
#  * exec:  sudo docker container exec -it domovik sh
#  * logs:  sudo docker container logs --follow --tail 100 domovik
CMD ["start"]
