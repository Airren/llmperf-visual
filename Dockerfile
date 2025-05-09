FROM python:3.10

RUN apt-get update && apt-get install -y --no-install-recommends --fix-missing vim

#RUN git clone https://github.com/Airren/llmperf-visual/
COPY . /llmperf-visual

WORKDIR llmperf-visual

RUN pip install -e .
