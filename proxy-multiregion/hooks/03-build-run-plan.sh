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
