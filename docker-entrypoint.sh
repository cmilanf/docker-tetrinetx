#!/bin/sh
if [ -z "$OP_PASSWORD" ]; then
	OP_PASSWORD=$(date +%s | sha256sum | base64 | head -c 8 ; echo)
fi
sleep 2
if [ -z "$QUERY_PASSWORD" ]; then
	QUERY_PASSWORD=$(date +%s | sha256sum | base64 | head -c 8 ; echo)
fi
sleep 2
if [ -z "$SPEC_PASSWORD" ]; then
        SPEC_PASSWORD=$(date +%s | sha256sum | base64 | head -c 8 ; echo)
fi
sleep 2
if [ -z "$SPEC_OP_PASSWORD" ]; then
	SPEC_OP_PASSWORD=$(date +%s | sha256sum | base64 | head -c 8 ; echo)
fi
if [ -z "$TETRINET_SERVER_URL" ]; then
	TETRINET_SERVER_URL=$HOSTNAME
fi

sed -i "s|op_password=pass4word|op_password=$OP_PASSWORD |g" /opt/tetrinetx/bin/game.secure
sed -i "s|query_password=pass4word|query_password=$QUERY_PASSWORD |g" /opt/tetrinetx/bin/game.secure
sed -i "s|spec_password=pass4word|spec_password=$SPEC_PASSWORD |g" /opt/tetrinetx/bin/game.secure
sed -i "s|spec_op_password=pass4word|spec_op_password=$SPEC_OP_PASSWORD |g" /opt/tetrinetx/bin/game.secure
sed -i "s|{{TETRINET_SERVER_URL}}|$TETRINET_SERVER_URL|g" /www/index.html
sed -i "s|{{TETRINET_SERVER_URL}}|$TETRINET_SERVER_URL|g" /opt/tetrinetx/bin/game.motd

exec "$@"
