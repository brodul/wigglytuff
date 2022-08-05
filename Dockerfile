FROM python:3.10

WORKDIR /usr/src/app
RUN pip install poetry

RUN apt-get clean && apt-get -y update && apt-get install -y ffmpeg

COPY pyproject.toml poetry.lock ./
RUN poetry install

COPY fly.toml ./
COPY src ./wigglytuff/

CMD [ "poetry", "run", "gunicorn", "wigglytuff.wsgi:wsgi_entrypoint" ]
