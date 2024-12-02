#!/bin/sh

# Update Garry's Mod
${STEAMCMDDIR}/steamcmd.sh +login anonymous \
    +force_install_dir ${GMODDIR} +app_update ${GMODID} validate +quit

# Update game content
${STEAMCMDDIR}/steamcmd.sh +login anonymous \
    +force_install_dir ${CSSDIR} +app_update ${CSSID} validate +quit
if [ ! -z "${TF2DIR}" ]; then
    ${STEAMCMDDIR}/steamcmd.sh +login anonymous \
        +force_install_dir ${TF2DIR} +app_update ${TF2ID} validate +quit
else
    sed -i '/force_install_dir ${TF2DIR}/d' /home/steam/updatescript.txt
    sed -i '/app_update ${TF2ID}/d' /home/steam/updatescript.txt
fi

echo "gamemode ${GAMEMODE}" >> ${SERVERCFG_DIR}/autoexec.cfg

MOUNT_CONFIG="${SERVERCFG_DIR}/mount.cfg"

# Mount game content
update_mount() {
    local mount_key="$1"
    local mount_path="$2"
    if ! grep -q "\"${mount_key}\"\s\"${mount_path}\"" "${MOUNT_CONFIG}"; then
        sed -i "/\"${mount_key}\"/d" "${MOUNT_CONFIG}"
        sed -i "/^\s*}/ i \ \"${mount_key}\"\t\"${mount_path}\"" "${MOUNT_CONFIG}"
    fi
}

# Check if the mount config file exists; otherwise, copy the default
if [ -f "${MOUNT_CONFIG}" ]; then
    update_mount "cstrike" "${CSSDIR}/cstrike"
    if [ ! -z "${TF2DIR}" ]; then
        update_mount "tf" "${TF2DIR}/tf"
    fi
else
    cp mount.cfg "${MOUNT_CONFIG}"
fi

# Update server config file
touch ${SERVERCFG}

update_config() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}[[:space:]]" "${SERVERCFG_DIR}/server.cfg"; then
        sed -i "s|^${key}[[:space:]].*|${key} ${value}|" "${SERVERCFG_DIR}/server.cfg"
    else
        echo "${key} ${value}" >> "${SERVERCFG_DIR}/server.cfg"
    fi
}

if [ ! -z "${DOWNLOADURL}" ]
then
    ALLOW_UPLOAD="1"
    ALLOW_DOWNLOAD="1"
fi


# Define an associative array mapping variable names to config keys
declare -A TTT_CONFIG=(
    [HOSTNAME]="hostname"
    [DOWNLOADURL]="sv_downloadurl"
    [ALLOW_UPLOAD]="sv_allowupload"
    [ALLOW_DOWNLOAD]="sv_allowdownload"
    [LOADINGURL]="sv_loadingurl"
    [PASSWORD]="sv_password"
    [RCONPASSWORD]="rcon_password"
    [TTT_FIRSTPREPTIME]="ttt_firstpreptime"
    [TTT_POSTTIME_SECONDS]="ttt_posttime_seconds"
    [TTT_PREPTIME_SECONDS]="ttt_preptime_seconds"
    [TTT_POSTROUND_DM]="ttt_postround_dm"
    [TTT_NO_NADE_THROW_DURING_PREP]="ttt_no_nade_throw_during_prep"
    [TTT_KARMA_RATIO]="ttt_karma_ratio"
    [TTT_DETECTIVE_HATS]="ttt_detective_hats"
    [TTT_HASTE]="ttt_haste"
    [TTT_TIME_LIMIT_MINUTES]="ttt_time_limit_minutes"
    [TTT_TRAITOR_PCT]="ttt_traitor_pct"
    [TTT_TRAITOR_MAX]="ttt_traitor_max"
    [TTT_DETECTIVE_PCT]="ttt_detective_pct"
    [TTT_DETECTIVE_MAX]="ttt_detective_max"
    [TTT_DETECTIVE_MIN_PLAYERS]="ttt_detective_min_players"
    [TTT_NAMECHANGE_KICK]="ttt_namechange_kick"
    [TTT_NAMECHANGE_BANTIME]="ttt_namechange_bantime"
)

# Loop through the array and update the config if the variable is set
for var in "${!TTT_CONFIG[@]}"; do
    value="${!var}"  # Get the value of the environment variable
    if [ ! -z "${value}" ]; then
        update_config "${TTT_CONFIG[$var]}" "${value}"
    fi
done


# Start the server
if [ -z "${GMODPORT}" ]
then
    GMODPORT=27015
fi
if [ -z "${CLIENTPORT}" ]
then
    CLIENTPORT=27005
fi
if [ -z "${MAXPLAYERS}" ]
then
    MAXPLAYERS=20
fi
if [ -z "${GAMEMAP}" ]
then
    GAMEMAP=gm_flatgrass
fi

# Base command
CMD="${GMODDIR}/srcds_run \
    -autoupdate \
    -steam_dir ${STEAMCMDDIR} \
    -steamcmd_script /home/steam/updatescript.txt \
    -port ${GMODPORT} \
    -clientport ${CLIENTPORT} \
    -maxplayers ${MAXPLAYERS} \
    -game garrysmod \
    +map ${GAMEMAP}"

# Add optional parameters
[ ! -z "${WORKSHOPID}" ] && CMD="${CMD} +host_workshop_collection ${WORKSHOPID}"
[ ! -z "${LOGINTOKEN}" ] && CMD="${CMD} +sv_setsteamaccount ${LOGINTOKEN}"
[ ! -z "${WORKSHOP_AUTHKEY}" ] && CMD="${CMD} -authkey ${LOGINTOKEN}"

# Execute the command
exec ${CMD}