FROM python:3.11-slim

## system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# set pixi home
ENV PIXI_HOME=/opt/pixi
## install pixi
RUN curl -fsSL https://pixi.sh/install.sh | bash
# set pixi environment variables
ENV PATH=$PIXI_HOME/bin:$PATH

WORKDIR /app

## copy project files
COPY pixi.toml pixi.lock ./

## changing the working directory to the notebook location
WORKDIR /app

## installing pixi env
RUN pixi install --locked && rm -rf ~/.cache/rattler

COPY ./src ./

## entries
ENTRYPOINT [ \
    "pixi", \
    "run", \
    "papermill", \
    "quality_volume_payout.ipynb", \
    "output.ipynb", \
    "--log-output" \
]

CMD []
