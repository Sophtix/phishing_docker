FROM debian:stable-slim

# install flask dependencies and gunicorn
RUN apt-get -y update && apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-dev build-essential && \
    pip3 install --upgrade pip && \
    apt-get -y autoremove && apt-get -y clean && rm -rf /var/lib/apt/lists/*

# copy the antirelay source code
COPY ./antirelay /opt/antirelay

# install app requirements
RUN pip3 install -r /opt/antirelay/requirements.txt

# set the working directory
WORKDIR /opt/antirelay

# expose ports
EXPOSE 80

# run gunicorn with flask app
CMD ["gunicorn", "-b", "0.0.0.0:80", "wsgi:app"]
