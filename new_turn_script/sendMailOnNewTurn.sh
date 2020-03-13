#!/bin/bash

LAST_TURN_FILE='./lastTurn'
MAIL_TEMPLATE_FILE='./mailTemplate.txt'
AWS_SES_HOST="email-smtp.eu-west-1.amazonaws.com:587"

date '+%Y-%m-%d %H:%M'

LAST_READ_TURN=`cat "$LAST_TURN_FILE" 2>/dev/null || echo '0'`
echo -e "Last turn:\t\t'$LAST_READ_TURN' in '$LAST_TURN_FILE'"


LATEST_SAVE_FILENAME=`ls -l|grep auto.sav.bz2|sort -r| head -n 1|cut -d ' ' -f 12`

if [ -z $LATEST_SAVE_FILENAME ]; then
	echo "No last save filename found"
	exit 1;	
fi

LAST_TURN=`echo "$LATEST_SAVE_FILENAME"|cut -d '-' -f 2`
echo -e "Last turn done:\t\t'$LAST_TURN' from '$LATEST_SAVE_FILENAME'"

IS_NEW_TURN=false

if [ "$LAST_READ_TURN" != "$LAST_TURN" ]; then
	IS_NEW_TURN=true
	
	echo -e "Setting last turn to:\t$LAST_TURN"
	echo "$LAST_TURN" > "$LAST_TURN_FILE"
fi;

echo -e "Is this a new turn?\t$IS_NEW_TURN"


if [ $IS_NEW_TURN = "true" ]; then
	echo "##########################################################"
	echo "# Sending trigger that this is a next turn"
	echo "##########################################################"
		
	MAIL_CONTENT=`cat "$MAIL_TEMPLATE_FILE"`
	MAIL_CONTENT="${MAIL_CONTENT//##TURN_NUMBER##/$LAST_TURN}"

	echo -e "$MAIL_CONTENT" | openssl s_client -crlf -quiet -starttls smtp -connect "$AWS_SES_HOST"
fi;
