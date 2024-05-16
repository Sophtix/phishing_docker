FROM python:3.11

# update system and install dependencies
RUN apt-get update -y && \
        apt-get install python3-full python3-pip -y && \
        apt-get clean -y && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m -d /opt/antirelay -s /bin/bash app

WORKDIR /opt/antirelay

# copy the antirelay source code
COPY ./antirelay .

USER app

RUN python3 -m venv venv && \
    . venv/bin/activate

# install app requirements
RUN pip install -r requirements.txt

# expose ports
EXPOSE 80

# run gunicorn with flask app
CMD ["python3", "-m", "gunicorn", "-b", "0.0.0.0:80", "wsgi:app"]