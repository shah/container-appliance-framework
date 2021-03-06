#!/bin/bash

if [ "$(whoami)" != "root" ]; then
	echo "Please use sudo to run this script, you must be root."
	exit 1
fi

# Default to allowing non-privileged users from mounting davfs2 paths
cat <<EOF | debconf-set-selections
davfs2 davfs2/suid_file boolean false
EOF
apt install -y davfs2

FSTAB=/etc/fstab
DAVFS2_CONF_FILE=/etc/davfs2/davfs2.conf
DAVFS2_SECRETS_FILE=/etc/davfs2/secrets
if [ ! -f $DAVFS2_SECRETS_FILE ]; then
    echo "$DAVFS2_SECRETS_FILE does not exist, put your secrets in there in the following format:"
    echo "    <URL> <username> <password>"
    exit 1
fi

DAVFS2_SECRETS_PERM=$(stat -c %A $DAVFS2_SECRETS_FILE)
if [ $DAVFS2_SECRETS_PERM != "-rw-------" ]; then
    echo "$DAVFS2_SECRETS_FILE doesn't have proper permissions."
    echo "run sudo chmod 600 $DAVFS2_SECRETS_FILE"
    exit 1
fi

WEBDAV_SERVER_FQDN=$1
WBEDAV_URL_PATH=$2
LOCAL_MOUNT_PATH=$3

if [ -z "$WEBDAV_SERVER_FQDN" ]; then
    echo "A WebDAV Fully Qualified Domain Name (FQDN) is expected in the first parameter."
    exit 1
fi

if [ -z "$WBEDAV_URL_PATH" ]; then
    echo "A WebDAV path (what comes after the FQDN) is expected in the second parameter."
    exit 1
fi

if [ -z "$LOCAL_MOUNT_PATH" ]; then
    echo "A local directory to mount the WebDAV URL is expected as the third parameter."
    exit 1
fi

if [ ! -d $LOCAL_MOUNT_PATH ]; then
    echo "Directory $LOCAL_MOUNT_PATH does not exist, please create it."
    echo "   sudo mkdir -p $LOCAL_MOUNT_PATH"
    exit 1
else
    echo "Mount path $LOCAL_MOUNT_PATH exists."
fi

WEBDAV_URL="https://$WEBDAV_SERVER_FQDN$WBEDAV_URL_PATH"

#echo "Accepting SSL certificate for $WEBDAV_URL"
#openssl s_client -showcerts -connect ${WEBDAV_SERVER_FQDN}:443 < /dev/null 2> /dev/null | \
#   openssl x509 -outform PEM | \
#   sudo tee /etc/davfs2/certs/${WEBDAV_SERVER_FQDN}.pem
#ls -al /etc/davfs2/certs

#if grep -Fxq "trust_server_cert $WEBDAV_SERVER_FQDN" $DAVFS2_CONF_FILE
#then
#    echo "Already trusted $WEBDAV_SERVER_FQDN in $DAVFS2_CONF_FILE"
#else
#    echo "trust_server_cert ${WEBDAV_SERVER_FQDN}" | sudo tee -a $DAVFS2_CONF_FILE
#fi

WEBDAV_URL_USERNAME_PASSWD=$(grep -F "$WEBDAV_URL" $DAVFS2_SECRETS_FILE)
if [ -z "$WEBDAV_URL_USERNAME_PASSWD" ]; then
    echo "Unable to find '$WEBDAV_URL' in $DAVFS2_SECRETS_FILE."
    echo "Please sudo vi $DAVFS2_SECRETS_FILE and add it there."
    exit 100
else
    echo "Found $WEBDAV_URL in $DAVFS2_SECRETS_FILE"
    IFS=' ' read -r -a secrets <<< "$WEBDAV_URL_USERNAME_PASSWD"
    testUrlResult=$(curl -L -w %{http_code} -X PROPFIND -H "Depth: 1" --anyauth --user "${secrets[1]}:${secrets[2]}" -s --output /dev/null $WEBDAV_URL)
    echo "Result of CURL on '$WEBDAV_URL' is: '$testUrlResult'."
    if [ "$testUrlResult" != "207" ]; then
        echo "The status should be 207, perhaps the WEBDAV_URL is not valid?"
        exit 101
    fi
fi

FSTAB_BACKUP=$FSTAB.orig.`date "+%Y-%m-%d.%H-%M-%S"`
echo "Deleting $WEBDAV_URL from $FSTAB, with backup at $FSTAB_BACKUP"
grep -vwE "$WEBDAV_URL" $FSTAB > $FSTAB.new
cp $FSTAB $FSTAB_BACKUP
mv $FSTAB.new $FSTAB

echo "Adding $WEBDAV_URL to $FSTAB, it should auto-mount on reboot"
echo "${WEBDAV_URL} $LOCAL_MOUNT_PATH davfs _netdev,x-systemd.automount 0 0" | \
    sudo tee -a $FSTAB
ls -al $FSTAB

if mountpoint $LOCAL_MOUNT_PATH
then
    echo "Flushing the cache and unmounting $LOCAL_MOUNT_PATH"
    umount $LOCAL_MOUNT_PATH
else
    echo "$LOCAL_MOUNT_PATH is not mounted, no unmount required."
fi

echo "Mounting $WEBDAV_URL to $LOCAL_MOUNT_PATH"
mount -t davfs ${WEBDAV_SERVER_URL} $LOCAL_MOUNT_PATH

echo ""
echo "ls -al $LOCAL_MOUNT_PATH"
ls -al $LOCAL_MOUNT_PATH

# sudo chmod +x setup-davfs2.sh && sudo ./setup-davfs2.sh sync.citushealth.com /account/CHA_CHMDF01P /mnt/davfs/CHA_CHMDF01P

