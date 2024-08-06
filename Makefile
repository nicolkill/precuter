IMAGE := hexpm/elixir:1.15.6-erlang-26.1.1-alpine-3.18.4
RUN_STANDARD := docker run --rm -v `pwd`:/app -w /app $(IMAGE)

all: build

up:
	docker compose up

build:
	$(RUN_STANDARD) sh -c 'apk update && mix do local.rebar --force, local.hex --force, \
                           		deps.get, \
                           		deps.compile --force, \
                           		compile --plt'

testing:
	$(RUN_STANDARD) sh -c 'apk update && MIX_ENV=test mix do local.hex --force, \
                                               		test'

iex:
	$(RUN_STANDARD) iex -S mix

bash:
	docker run --rm -t -v `pwd`:/app -w /app elixir:latest sh

format:
	$(RUN_STANDARD) mix format