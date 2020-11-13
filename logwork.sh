#!/bin/bash
# .____    ________    __________      __________ __________ ____  __.
# |    |   \_____  \  /  _____/  \    /  \_____  \\______   \    |/ _|
# |    |    /   |   \/   \  __\   \/\/   //   |   \|       _/      <  
# |    |___/    |    \    \_\  \        //    |    \    |   \    |  \ 
# |_______ \_______  /\______  /\__/\  / \_______  /____|_  /____|__ \
#         \/       \/        \/      \/          \/       \/        \/
#
# Author: Shane Breining
# Date:   2020, November 10th
#
# This simple script (with admittedly minimal validation) helps the
# developer log their time worked on a ticket from the command line
# via a cURL request to JIRA. It requires two pieces of information
# and  the  first  is  simply  your  username.  The second piece of
# information is a token  that can be generated in your profile  on
# Atlassian's website.  From Jira (domain.atlassian.net),  click on
# your profile icon on the top left and click on "Account Settings"
# From there, navigate to "Security", and in there click on "Create
# and manage API tokens." From there,  create a new API token using
# the  button at the top. The name is irrelevant, however, copy  it
# to your clipboard, and paste it here in the variable  JIRA_TOKEN.
# Once, you have your username and token filled into the variables,
# you can run the script.
#
# The output  of the rest request will be  logged to  /tmp/logwork/
# directory.  If you don't get  an e-mail that  you logged  time to
# your ticket, check the file  (date).log for the  failure message.
#
# Example usage: logwork -t DEV-101 -w 5h30m
#                logwork -t DEV-102 -w 45m
#                logwork -t DEV-103 -w 2h
#
# Happy programming!

JIRA_USER="YOUR_USERNAME"
JIRA_TOKEN="YOUR_TOKEN/PASSWORD"
DOMAIN="COMPANY_DOMAIN"

# Make a temp file for capturing output if one does not exist.
[ ! -d "/tmp/logwork" ] && mkdir /tmp/logwork

# Show usage information
usage() {
  cat >&2 <<EOF
Usage:
  $0 [-h | -t TICKET -w WORK_TIME]
  Example: $0 -t DEV-101 -w 5h30m

This script logs work for the given [TICKET] for the
[WORK_TIME]

OPTIONS:
  -h              Show usage information (this message).
  -t TICKET       The Jira ticket name (ie DEV-101)
  -w TIME         Amount of time worked (ie 5h30m)
EOF
}

# Convert time provided into seconds for API call.
convertTime() {
  HOURS=$(echo $1 | cut -d'h' -f 1)
  MINUTES=$(echo $1 | cut -d'h' -f 2 | cut -d'm' -f 1)

  TIME=0
  if [[ $MINUTES =~ ^[0-9]+$ ]]; then TIME=$(($TIME + 60 * $MINUTES)); fi
  if [[ $HOURS =~ ^[0-9]+$ ]]; then TIME=$(($TIME + 3600 * $HOURS)); fi

  echo $TIME
}

# Parse Options
while getopts ":t:w:h" flag; do
  case "${flag}" in
    h)
      usage
      exit 3
      ;;
    t)
      TICKET=${OPTARG}
      ;;
    w)
      WORK_TIME=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument"
      exit 1
      ;;
  esac
done

# Shift past all parsed arguments
shift $((OPTIND-1))

# Make sure arguments were passed in.
test -z "$TICKET" && usage && echo "No ticket specified!" && exit 1
test -z "$WORK_TIME" && usage && echo "Need amount of work time" && exit 1

TIME_SECONDS=$(convertTime $WORK_TIME)
FORMATTED_DATE=$(date +"%Y-%m-%dT%H:%M:%S.000-0800")
LOG_FILE="$(date +"%Y-%m-%d").log"

echo "---------------------------------"
echo ".-^-.-^-. L O G W O R K .-^-.-^-."
echo "---------------------------------"
echo "Sending $WORK_TIME to $TICKET on Jira."

# Send CURL to JIRA.
curl -s -D- \
  -u $JIRA_USER:$JIRA_TOKEN \
  -X POST -H "Content-Type: application/json" \
  -d '{"comment":"Work was done","started":"'$FORMATTED_DATE'","timeSpentSeconds":'$TIME_SECONDS'}' \
  https://$DOMAIN.atlassian.net/rest/api/2/issue/$TICKET/worklog \
  > /tmp/logwork/$LOG_FILE

STATUS=$(head -n 1 /tmp/logwork/$LOG_FILE | sed -E -e "s/^HTTP\/2 ([0-9]+)/\1/")

echo "HTTP response status of: $STATUS"
echo "For more details, please refer to /tmp/logwork/$LOG_FILE"
echo "---------------------------------"
