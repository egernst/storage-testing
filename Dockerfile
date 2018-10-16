FROM ubuntu

RUN apt-get update; apt-get install -y fio

COPY ./entrypoint.sh /

#ENTRYPOINT ["/usr/bin/fio"]
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["fio"]

#ENTRYPOINT ["/bin/bash"]
