FROM docker.io/alpine:3.19.0

RUN apk --no-cache add exim tini && \
    mkdir /var/spool/exim && \
    chmod 777 /var/spool/exim && \
    ln -sf /dev/stdout /var/log/exim/mainlog && \
    ln -sf /dev/stderr /var/log/exim/panic && \
    ln -sf /dev/stderr /var/log/exim/reject && \
    chmod 0755 /usr/sbin/exim


# RUN apt-get update && \
#    apt-get install -y exim4 tini && \
#    mkdir /var/spool/exim && \
#    chmod 777 /var/spool/exim && \
#    ln -sf /dev/stdout /var/log/exim/mainlog && \
#    ln -sf /dev/stderr /var/log/exim/panic && \
#    ln -sf /dev/stderr /var/log/exim/reject && \
#    chmod 0755 /usr/sbin/exim && \
#    apt-get clean;rm -rf /var/lib/apt/lists/*;


COPY exim.conf /etc/exim/exim.conf

# Regardless of the permissions of the original `exim.conf` file in the build context,
# ensure that the `/etc/exim/exim.conf` configuration file is not writable by the Exim user.
# Otherwise, we'll get an Exim panic:
# > Exim configuration file /etc/exim/exim.conf has the wrong owner, group, or mode
RUN chmod 664 /etc/exim/exim.conf

USER exim
# USER Debian-exim

EXPOSE 8025

ENV LOCAL_DOMAINS=@ \
    RELAY_FROM_HOSTS=10.0.0.0/8:172.16.0.0/12:192.168.0.0/16 \
    RELAY_TO_DOMAINS=* \
    RELAY_TO_USERS= \
    DISABLE_SENDER_VERIFICATION= \
    HOSTNAME= \
    SMARTHOST= \
    SMTP_PASSWORD= \
    SMTP_USERDOMAIN= \
    SMTP_USERNAME=


ENTRYPOINT ["/sbin/tini", "--"]
#ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["exim", "-bdf", "-q15m"]
#CMD ["/usr/sbin/exim", "-bdf", "-q15m"]
