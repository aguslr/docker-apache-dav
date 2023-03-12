#!/bin/sh

# Create HTTP user
if [ "${HTTP_USER:=httpuser}" ] && ! grep -s "^${HTTP_USER}" /etc/apache2/htpasswd; then
	# Generate random password
	[ -z "${HTTP_PASS}" ] && \
		HTTP_PASS=$(date +%s | sha256sum | base64 | head -c 32) && gen_pass=1
	# Add user to password file
	if [ -f /etc/apache2/htpasswd ]; then
		if printf '%s' "${HTTP_PASS}" \
			| htpasswd -i /etc/apache2/htpasswd "${HTTP_USER}" && \
			[ "${gen_pass}" -eq 1 ]; then
			printf 'Password for %s is %s\n' "${HTTP_USER}" "${HTTP_PASS}"
		fi
	else
		if printf '%s' "${HTTP_PASS}" \
			| htpasswd -i -c /etc/apache2/htpasswd "${HTTP_USER}" && \
			[ "${gen_pass}" -eq 1 ]; then
			printf 'Password for %s is %s\n' "${HTTP_USER}" "${HTTP_PASS}"
		fi
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
