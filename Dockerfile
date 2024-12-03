# Debian base image with SteamCMD
FROM cm2network/steamcmd:root

# Internal Settings
ENV GMODID=4020 \
    GMODDIR=/home/steam/gm \
    CSSID=232330 \
    CSSDIR=/home/steam/css \
    TF2ID=232250 \
    TF2DIR=/home/steam/tf2 \
    SERVERCFG_DIR=/home/steam/gm/garrysmod/cfg \
    GAMEMODE=terrortown

# Environment variables
ENV HOSTNAME="A TTT Server" \
    GMODPORT=27015 \
    CLIENTPORT=27005 \
    MAXPLAYERS=20 \
    GAMEMAP=gm_flatgrass \
    WORKSHOPID="" \
    DOWNLOADURL="" \
    LOADINGURL="" \
    PASSWORD="" \
    RCONPASSWORD="" \
    LOGINTOKEN=""

# Add files
WORKDIR /home/steam/
COPY --chown=steam mount.cfg updatescript.txt ./
COPY --chown=steam ttt.sh .
RUN chmod a+rx ttt.sh

# Start main script
USER steam
CMD ./ttt.sh

# Set up container
EXPOSE 27015/udp 27005/udp
VOLUME ${GMODDIR} ${CSSDIR} ${TF2DIR}