#!/bin/sh

# Create HTTP user
if [ "${HTTP_USER:=httpuser}" ] && ! grep -s "^${HTTP_USER}" /etc/apache2/htpasswd; then
	# Generate random password
	[ -z "${HTTP_PASS}" ] && \
		HTTP_PASS=$(date +%s | sha256sum | base64 | head -c 32) && \
		printf 'Password for %s is %s\n' "${HTTP_USER}" "${HTTP_PASS}"
	# Add user to password file
	if [ -f /etc/apache2/htpasswd ]; then
		printf '%s' "${HTTP_PASS}" | htpasswd -i /etc/apache2/htpasswd "${HTTP_USER}"
	else
		printf '%s' "${HTTP_PASS}" | htpasswd -i -c /etc/apache2/htpasswd "${HTTP_USER}"
	fi
	# Add user to admin group
	if [ -f /etc/apache2/htgroup ]; then
		sed -i "/^admin:/s/ .*$/ ${HTTP_USER}/" /etc/apache2/htgroup
	else
		printf 'admin: %s\n' "${HTTP_USER}" > /etc/apache2/htgroup
	fi
fi

# Start Apache
/usr/sbin/apache2ctl "$@"
