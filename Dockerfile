FROM ubuntu:focal

RUN apt-get update && \
    apt-get install -y ffmpeg curl libavcodec-extra-53





COPY audiologger.sh /usr/local/bin/audiologger.sh
RUN chmod +x /usr/local/bin/audiologger.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY config.sh /usr/local/bin/config.sh
RUN chmod +x /usr/local/bin/config.sh

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "bash" ]

