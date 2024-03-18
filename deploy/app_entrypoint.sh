#!/bin/bash

#. ./.env
#. ./.local.env

mix deps.get
mix deps.compile
mix compile
exec iex -S mix
#exec /bin/bash

