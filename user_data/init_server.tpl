#!/bin/bash
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo apt-get install nginx -y
sudo apt-get install php-fpm php-mysql php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc -y
sudo apt-get install python-pip -y
sudo pip install --upgrade pip
sudo pip install awscli --upgrade

#Download & configure WordPress version
sudo rm -f /var/www/html/*
cd /tmp
sudo wget https://wordpress.org/latest.tar.gz
sudo tar zvxf latest.tar.gz
sudo mv wordpress/* /var/www/html/
cd /var/www/html
cat <<'EOF' >/var/www/html/health.htm
ok
EOF
rm -rf wp-content/*
aws s3 sync s3://${replica_bucket_name} wp-content --delete
sudo chown -R www-data:www-data .
sudo chmod -R 755 wp-content

#Configuring wp-config file
cat <<'EOF' >/tmp/wp-config.php
<?php
define('DB_NAME', '${db_name}');
define('DB_USER', '${db_user}');
define('DB_PASSWORD', '${db_pass}');
define('DB_HOST', '${db_host}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         '2SR8yHuxOU8)0P|rBXqZ%&!/]vt*,Gp/5jJ*/|Jge d >h3F6,4.3zt),d!1P|#d');
define('SECURE_AUTH_KEY',  '7x?[F*vo/!eL[*f&aF1o5a^+i>=97`cJV3slJq;-LIEyV;`6[%u*mmv$Y$0TqMn0');
define('LOGGED_IN_KEY',    'Ga ][c27d8QsVL=p$M?2&*`!246.Gby6E,SI23r?8jpr~=@wvN*VRg1yV(Y ~t<f');
define('NONCE_KEY',        'Ya1)zQLD hlD5AX`UdIam6/Z}gC*zs;orv+d(O4MNb.wHHmg!`g+)[IW6;]Etg=H');
define('AUTH_SALT',        '5C*,b/m09*]<04n*tt2gI,_*N%`Ea)$Pw4!wM!c;+p 6IUwb1+;L`Hp!+2z13.N7');
define('SECURE_AUTH_SALT', 'nX5J,*=!~0l=sh-W-gBdTx++HeAt9%zqafdi1tu(?Ua|daZ#uIXr|lT.V&>Z>+~J');
define('LOGGED_IN_SALT',   'H:b)dRQ]M=maIH+1pw<[V0f2m#v2-aA/A]%0!<:mNmZRSOL8(&#E|0Aq[vC,Saht');
define('NONCE_SALT',       '):.,Fz!Fx3cpjhv~XunP9$f|<i|wQ<^Jh38c?q0|zBW`2v]#eIB,At!.%9RCmd3r');

$table_prefix  = 'wp_';
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
EOF
sudo mv /tmp/wp-config.php /var/www/html/

#syncro operations
cat << 'EOF' >/etc/cron.d/sync
#!/bin/bash
aws s3 sync s3://${replica_bucket_name} /var/www/html/wp-content
aws s3 sync /var/www/html/wp-content s3://${replica_bucket_name}
chown -R www-data:www-data /var/www/html/wp-content
chmod -R 755 /var/www/html/wp-content
EOF
sudo chmod +x /etc/cron.d/sync
sudo echo "*/5 * * * * root /etc/cron.d/sync" >> /etc/crontab


#set-up nginx for hosting the WordPress website
sudo echo "cgi.fix_pathinfo=0" >> /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm

cat <<'EOF' >/tmp/nginx.conf
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm index.nginx-debian.html;

    server_name _;

    location ~ /\.ht {
        deny all;
    }
    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt { log_not_found off; access_log off; allow all; }
    location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
        expires max;
        log_not_found off;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }

    # Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
    # Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
    location ~ /\. {
        deny all;
    }

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    # Deny access to any files with a .php extension in the uploads directory
    # Works in sub-directory installs and also in multisite network
    # Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
    location ~* /(?:uploads|files)/.*\.php$ {
	    deny all;
    }
}
EOF

sudo mv /tmp/nginx.conf /etc/nginx/sites-available/default
sudo systemctl reload nginx