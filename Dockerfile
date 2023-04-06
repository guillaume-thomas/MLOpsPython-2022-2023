FROM python:3.11.2-bullseye

ENV APP_ROOT=/opt/app-root

WORKDIR ${APP_ROOT}

COPY boot.py ./boot.py
COPY packages ./packages
COPY production ./production

RUN python -m pip install --upgrade pip
RUN python -m pip install --upgrade setuptools wheel
RUN pip install -e packages/inference

WORKDIR ${APP_ROOT}/packages/inference

RUN python setup.py sdist bdist_wheel

WORKDIR ${APP_ROOT}

RUN cp ./packages/inference/dist/*.whl production/api/packages
RUN pip install -e packages/extraction

WORKDIR ${APP_ROOT}/packages/extraction

RUN python setup.py sdist bdist_wheel

WORKDIR ${APP_ROOT}

RUN cp ./packages/extraction/dist/*.whl production/api/packages
RUN pip install -r production/api/requirements.txt

EXPOSE 8080

ENTRYPOINT ["python3", "boot.py"]