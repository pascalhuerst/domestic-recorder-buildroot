#!/usr/bin/bash

HOSTNAME=$(hostname)
MESSAGE="[${HOSTNAME}]: ${1}"

curl --insecure -X POST -H 'Content-type: application/json' --data "{\"text\":\"${MESSAGE}\"}" https://hooks.slack.com/services/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 2>/dev/null 1>/dev/null
RET=$?

if [ ${RET} -eq 0 ]; then
	echo "[SLACK]: Successfully Deployed Message: ${MESSAGE}"
else
	echo "[SLACK]: Error Deploying Message: ${MESSAGE}"
fi
