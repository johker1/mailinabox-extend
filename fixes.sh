sed -i '0,/if (sizeof($message->getFrom()) === 0) {/s/if (sizeof($message->getFrom()) === 0) {/$message->setFrom();\n&/' /usr/local/lib/owncloud/lib/private/Mail/Mailer.php
sed -ie '/if (sizeof($message->getFrom()) === 0) {/,+3 s/^/#/' /usr/local/lib/owncloud/lib/private/Mail/Mailer.php
