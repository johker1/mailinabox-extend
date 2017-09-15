	
echo "Adding Spreed ME Web RTc Server Ubuntu Repo and Instalation"
apt-add-repository ppa:strukturag/spreed-webrtc-unstable -y
apt update
apt dist-upgrade -y
apt install -y spreed-webrtc

echo "Enabling spreedme in rc.local"
echo "service spreed-webrtc start" >> /etc/rc.local
echo "Starting spreedme"
service spreed-webrtc start

echo "Adding coturn REPO"
add-apt-repository ppa:fancycode/coturn -y
apt update
apt dist-upgrade -y

echo "Adding turn Server has dependency of Spreed Me"
apt install coturn -y

echo "Enabling TURNSERVER in Config"
echo TURNSERVER_ENABLED=1 > /etc/default/coturn

echo "Making TURNSERVER in Config"

cat > /etc/turnserver.conf <<EOF
no-stun
listening-port=8443
tls-listening-port=3478
fingerprint
lt-cred-mech
use-auth-secret
static-auth-secret=a1bd247113a1713e569c1cba6294eba9ad88bd1281b449420773047fd9137966
realm=$HOSTNAME
total-quota=100
bps-capacity=0
stale-nonce
no-loopback-peers
no-multicast-peers

EOF

echo "Adding TURNSERVER and spreedme to Webrtc Conf"

cat > /etc/spreed/webrtc.conf<<'EOF'
; Minimal Spreed WebRTC configuration for Nextcloud

[http]
listen = 127.0.0.1:8080
basePath = /webrtc/
root = /usr/share/spreed-webrtc-server/www

[app]
sessionSecret = a922aa7e7d24fc4db87c73528d8fe3456b903716e4fb80280e42d9ba2ef650e2
encryptionSecret = 692a2e89adc9834c9333bc578f472f5f7be1176e5d78e32c8d403c2c2a2e2676
authorizeRoomJoin = true
serverToken = 3e0b42e59ec1288420c177a53888b11d9c9e5b78930fee5b3b46d2c10679745e
serverRealm = local
extra = /usr/local/lib/owncloud/apps/spreedme/extra
plugin = extra/static/owncloud.js
turnURIs = turn:HOSTNAME:8443?transport=udp turn:HOSTNAME:8443?transport=tcp
turnSecret = a1bd247113a1713e569c1cba6294eba9ad88bd1281b449420773047fd9137966 
stunURIs = stun:stun.spreed.me:443 

[users]
enabled = true
mode = sharedsecret
sharedsecret_secret = 3ea124dcdcf3ca1c1d2dbba48ae525eb9f810abf4329476f98d0a27216a2bff5
EOF

sed -i -e "s/HOSTNAME/${HOSTNAME}/g" /etc/spreed/webrtc.conf

echo "Adding FW rule for 8443"
ufw allow 8443

echo "Generating SpreedME App config"
cat > /usr/local/lib/owncloud/apps/spreedme/config/config.php <<'EOF'
<?php
/**
 * Nextcloud - spreedme
 *
 * This file is licensed under the Affero General Public License version 3 or
 * later. See the COPYING file.
 *
 * @author Leon <leon@struktur.de>
 * @copyright struktur AG 2016
 */

namespace OCA\SpreedME\Config;

class Config {

	// Domain of your Spreed WebRTC server (including protocol and optional port number), examples:
	//const SPREED_WEBRTC_ORIGIN = 'https://mynextcloudserver.com';
	//const SPREED_WEBRTC_ORIGIN = 'https://webrtc.mynextcloudserver.com:8080';
	// If this is empty or only includes a port (e.g. :8080), host will automatically be determined (current host)
	const SPREED_WEBRTC_ORIGIN = '';

	// This has to be the same `basePath`
	// you already set in the [http] section of the `server.conf` file from Spreed WebRTC server
	const SPREED_WEBRTC_BASEPATH = '/webrtc/';

	// This has to be the same `sharedsecret_secret` (64-character HEX string)
	// you already set in the [users] section of the `server.conf` file from Spreed WebRTC server
	const SPREED_WEBRTC_SHAREDSECRET = '3ea124dcdcf3ca1c1d2dbba48ae525eb9f810abf4329476f98d0a27216a2bff5';

	// Set to true if at least one another Nextcloud instance uses the same Spreed WebRTC server
	const SPREED_WEBRTC_IS_SHARED_INSTANCE = false;

	// If set to false (default), all file transfers (e.g. when sharing a presentation or sending a file to another peer) are directly sent to the appropriate user in a peer-to-peer fashion.
	// If set to true, all files are first uploaded to Nextcloud, then this file is shared and can be downloaded by other peers. This is required e.g. when using an MCU.
	const SPREED_WEBRTC_UPLOAD_FILE_TRANSFERS = false;

	// Whether anonymous users (i.e. users which are not logged in) should be able to upload/share files and presentations
	// This value is only taken into account when 'SPREED_WEBRTC_UPLOAD_FILE_TRANSFERS' is set to true
	const SPREED_WEBRTC_ALLOW_ANONYMOUS_FILE_TRANSFERS = false;

	// Set to true if you want to allow access to this app + spreed-webrtc for non-registered users who received a temporary password by an Nextcloud admin.
	// You can generate such a temporary password at: /index.php/apps/spreedme/admin/tp (Nextcloud admin user account required)
	const OWNCLOUD_TEMPORARY_PASSWORD_LOGIN_ENABLED = true;

	private function __construct() {

	}

}
EOF

sed -i -e '1i}\' /etc/nginx/conf.d/local.conf
sed -i -e '1i"''"    close;\' /etc/nginx/conf.d/local.conf
sed -i -e '1idefault    upgrade;\' /etc/nginx/conf.d/local.conf
sed -i -e '1imap $http_upgrade $connection_upgrade {\' /etc/nginx/conf.d/local.conf

awk '/Nextcloud/{while(getline line<"'$HOME'/mailinabox-extend/sme.conf"){print line}} //' /etc/nginx/conf.d/local.conf > tmp
cat tmp > /etc/nginx/conf.d/local.conf



