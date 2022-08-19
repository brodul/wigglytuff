FROM nixos/nix

WORKDIR /app
COPY docker/entrypoint.sh docker/entrypoint.sh
ENTRYPOINT [ "docker/entrypoint.sh" ]

COPY nix/ ./nix/
COPY pyproject.toml poetry.lock shell.nix ./
RUN nix-shell --argstr buildType prod --run "poetry install -n --no-dev"

COPY fly.toml ./
COPY src/wigglytuff ./wigglytuff/

CMD [ "gunicorn", "wigglytuff.wsgi:wsgi_entrypoint" ]
