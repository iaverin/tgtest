FROM python:3.12

# required for psycopg2
RUN apt update \
    && apt install -y --no-install-recommends \
        build-essential \
        libpq-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
RUN useradd --no-create-home --gid root runner

ENV UV_PYTHON_PREFERENCE=only-system
ENV UV_NO_CACHE=true

WORKDIR /code

COPY pyproject.toml .
COPY uv.lock .

RUN uv sync
# RUN uv sync --frozen --no-install-project

COPY . .
RUN chown -R runner:root /code && chmod -R g=u /code

USER runner

CMD ["uv","run", "uvicorn", "web:app", "--host", "0.0.0.0", "--port", "80"]
