## Generate an HTTP Basic Auth password
htpasswd:
	sudo apt-get install apache2-utils
	htpasswd -nb admin secure_password