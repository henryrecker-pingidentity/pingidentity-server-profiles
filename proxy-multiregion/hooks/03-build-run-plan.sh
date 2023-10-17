#!/usr/bin/env sh
#
# Ping Identity DevOps - Docker Build Hooks
#
#- This script is called to determine the plan for the server as it starts up.
#

# shellcheck source=../../../../pingcommon/opt/staging/hooks/pingcommon.lib.sh
. "${HOOKS_DIR}/pingcommon.lib.sh"

# shellcheck source=../../../../pingdatacommon/opt/staging/hooks/pingdata.lib.sh
. "${HOOKS_DIR}/pingdata.lib.sh"

test "${VERBOSE}" = "true" && set -x

# Set run plan defaults
RUN_PLAN="UNKNOWN"

SERVER_UUID_FILE="${SERVER_ROOT_DIR}/config/server.uuid"

if test -f "${SERVER_UUID_FILE}"; then
    RUN_PLAN="RESTART"
else
    RUN_PLAN="START"
fi

INSTANCE_NAME=$(getPingDataInstanceName)

echo_header "Run Plan Information"
echo_vars RUN_PLAN INSTANCE_NAME serverUUID
echo_bar

export_container_env RUN_PLAN INSTANCE_NAME

# Set run plan for joining PD topology if necessary
if test "$(toLower "${JOIN_PD_TOPOLOGY}")" != "true"; then
    echo "Backend discovery for PingDirectoryProxy will not be configured, because JOIN_PD_TOPOLOGY is not set to true."
    exit 0
fi

#TODO calculate this rather than requiring a single value - allow for connecting to any running PD for add-server
# Build a topology.json file maybe?
if test -z "${PINGDIRECTORY_HOSTNAME}" ||
    test -z "${PINGDIRECTORY_LDAPS_PORT}"; then
    container_failure 3 "One of PINGDIRECTORY_HOSTNAME: (${PINGDIRECTORY_HOSTNAME}), PINGDIRECTORY_LDAPS_PORT: (${PINGDIRECTORY_LDAPS_PORT}) aren't set. These variables must be set when JOIN_PD_TOPOLOGY is true."
fi

buildRunPlan
