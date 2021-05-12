#!/bin/bash

RS_CONTAINER_NAME=${1}
RS_CONTAINER_BASE=/share/apps/Singularity/rstudio_server
RS_CONTAINER_IMAGE=${RS_CONTAINER_BASE}/${RS_CONTAINER_NAME}

if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename ${0}) IMAGE"
    echo "Available images:"
    ls ${RS_CONTAINER_BASE}
    exit 1
fi

if [ ! -f ${RS_CONTAINER_IMAGE} ]; then
    echo "Error: R Studio container image not found"
    exit 1
fi

# Create rstudio image specific library path
RS_CONTAINER_R_LIBS_USER=${HOME}/R/${RS_CONTAINER_NAME}
mkdir -p ${RS_CONTAINER_R_LIBS_USER}

# Create session specific temporary directories
mkdir -p ${TMPDIR}/{tmp,var/lib/rstudio-server,var/run/rstudio-server,home/rstudio}

# Configure rstudio to use persistent library path
echo "Sys.setenv(R_LIBS_USER='${RS_CONTAINER_R_LIBS_USER}')" >> ${TMPDIR}/home/rstudio/.Rprofile

# System JAVA_HOME path should not override container path
echo "Sys.unsetenv('JAVA_HOME')" >> ${TMPDIR}/home/rstudio/.Rprofile

# Generate random password
RS_CONTAINER_PASSWD=$(openssl rand -base64 12)
echo "PASSWORD=${RS_CONTAINER_PASSWD}" > ${TMPDIR}/rs.passwd

# Pick random port number
while :
do
    RAND_PORT=$(shuf -i 50000-60000 -n 1)
    if netstat -l -t -n | grep -q -v ${RAND_PORT}; then
        break
    fi
done

# Print instructions for connecting
INSTRUCTIONS="
The following SSH commands should be run from your computer. If you are using PuTTY, you will need to adapt the settings.

    ssh -L 2022:brain.deohs.washington.edu:22 ${USER}@vector.deohs.washington.edu

Then in a separate terminal, run:

    ssh -p 2022 -L ${RAND_PORT}:${HOSTNAME}:${RAND_PORT} ${USER}@localhost

Once the SSH tunnel is setup, use a browser to visit http://localhost:${RAND_PORT}/, and login with ${USER} / ${RS_CONTAINER_PASSWD}
"
printf "${INSTRUCTIONS}"

# Start server
singularity exec \
--env-file ${TMPDIR}/rs.passwd \
--bind ${TMPDIR}/home/rstudio:/home/rstudio \
--bind ${TMPDIR}/var/lib/rstudio-server:/var/lib/rstudio-server \
--bind ${TMPDIR}/var/run/rstudio-server:/var/run/rstudio-server \
--bind ${TMPDIR}/tmp:/tmp \
${RS_CONTAINER_IMAGE} \
rserver --auth-none=0 --auth-pam-helper-path=pam-helper --www-port=${RAND_PORT}
