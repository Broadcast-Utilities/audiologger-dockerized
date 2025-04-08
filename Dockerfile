FROM ubuntu:focal

RUN apt-get update && \
    apt-get install -y ffmpeg curl libmp3lame0





COPY audiologger.sh /usr/local/bin/audiologger.sh
RUN chmod +x /usr/local/bin/audiologger.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh



ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "bash" ]

