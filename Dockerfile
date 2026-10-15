# 1. Define Global Arguments (Scope: All Stages)
ARG BUILDER_IMAGE=python:3.11-slim
ARG RUNTIME_IMAGE=docker.io/library/python:3.15-alpine@sha256:ff4d3c9b1a48f646eedd93182aaea385c7a5452f4c8a8cd7cef686babacf4928

# 2. Build Stage
FROM ${BUILDER_IMAGE} AS builder
WORKDIR /build

# In this stage, we might install heavy build tools
RUN apt-get update && apt-get install -y gcc g++
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# 3. Final Runtime Stage
FROM ${RUNTIME_IMAGE}
WORKDIR /app

# Note: Global ARGs must be re-declared inside a stage 
# if you want to use them in a RUN or ENV command.
ARG RUNTIME_IMAGE
ENV IMAGE_VERSION=${RUNTIME_IMAGE}

# Copy from builder stage
COPY --from=builder /root/.local /root/.local
COPY . .

# Ensure the scripts are in the PATH
ENV PATH=/root/.local/bin:$PATH

ENTRYPOINT ["python", "main.py"]
