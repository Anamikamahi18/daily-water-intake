#!/bin/bash

# AWS EC2 Ubuntu 22.04 LTS Deployment Script for Daily Water Intake Tracker
# Run this script as root or with sudo privileges

echo "=========================================="
echo "Starting deployment setup..."
echo "=========================================="

# Update system packages
echo "Updating system packages..."
apt update && apt upgrade -y

# Install required system packages
echo "Installing system packages..."
apt install -y python3 python3-pip python3-venv python3-dev
apt install -y mysql-server mysql-client libmysqlclient-dev
apt install -y nginx git curl ufw
apt install -y build-essential pkg-config

# Install additional MySQL dependencies
apt install -y default-libmysqlclient-dev

# Create application user
echo "Creating application user..."
adduser --system --group --home /opt/watertracker watertracker

# Create application directory
echo "Setting up application directory..."
mkdir -p /opt/watertracker/app
chown -R watertracker:watertracker /opt/watertracker

# Clone application (you'll need to update this with your repo URL)
echo "Cloning application..."
cd /opt/watertracker
sudo -u watertracker git clone https://github.com/Anamikamahi18/daily-water-intake.git app
cd app

# Create virtual environment
echo "Creating virtual environment..."
sudo -u watertracker python3 -m venv venv
sudo -u watertracker ./venv/bin/pip install --upgrade pip

# Install Python dependencies
echo "Installing Python dependencies..."
sudo -u watertracker ./venv/bin/pip install -r deployment/requirements.txt

# Setup MySQL
echo "Configuring MySQL..."
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation (you'll need to run this manually)
echo "Please run 'mysql_secure_installation' manually after this script completes"

# Create MySQL database and user
mysql -e "CREATE DATABASE IF NOT EXISTS daily_water_intake;"
mysql -e "CREATE USER IF NOT EXISTS 'watertracker'@'localhost' IDENTIFIED BY 'your_secure_password_here';"
mysql -e "GRANT ALL PRIVILEGES ON daily_water_intake.* TO 'watertracker'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Create environment file
echo "Creating environment configuration..."
cat > /opt/watertracker/app/.env << EOF
DEBUG=False
SECRET_KEY=your-very-secure-secret-key-here-change-this
DB_NAME=daily_water_intake
DB_USER=watertracker
DB_PASSWORD=your_secure_password_here
DB_HOST=localhost
DB_PORT=3306
ALLOWED_HOSTS=your-domain.com,your-ec2-ip-address,localhost
EOF

chown watertracker:watertracker /opt/watertracker/app/.env
chmod 600 /opt/watertracker/app/.env

# Run Django migrations
echo "Running Django migrations..."
cd /opt/watertracker/app/watertracker
sudo -u watertracker ../venv/bin/python manage.py migrate

# Collect static files
echo "Collecting static files..."
sudo -u watertracker ../venv/bin/python manage.py collectstatic --noinput

# Create directories for static and media files
mkdir -p /opt/watertracker/static
mkdir -p /opt/watertracker/media
chown -R watertracker:watertracker /opt/watertracker/static
chown -R watertracker:watertracker /opt/watertracker/media

# Setup Gunicorn service
echo "Setting up Gunicorn service..."
cat > /etc/systemd/system/watertracker.service << EOF
[Unit]
Description=Gunicorn instance to serve watertracker
Requires=watertracker.socket
After=network.target

[Service]
Type=notify
User=watertracker
Group=watertracker
RuntimeDirectory=watertracker
WorkingDirectory=/opt/watertracker/app/watertracker
Environment="PATH=/opt/watertracker/app/venv/bin"
ExecStart=/opt/watertracker/app/venv/bin/gunicorn \\
          --access-logfile - \\
          --workers 3 \\
          --bind unix:/run/watertracker/watertracker.sock \\
          watertracker.wsgi:application
ExecReload=/bin/kill -s HUP \$MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Setup Gunicorn socket
cat > /etc/systemd/system/watertracker.socket << EOF
[Unit]
Description=watertracker socket

[Socket]
ListenStream=/run/watertracker/watertracker.sock
SocketUser=www-data
SocketMode=660

[Install]
WantedBy=sockets.target
EOF

# Setup Nginx configuration
echo "Configuring Nginx..."
cat > /etc/nginx/sites-available/watertracker << EOF
server {
    listen 80;
    server_name your-domain.com your-ec2-ip-address;

    client_max_body_size 10M;

    location = /favicon.ico { 
        access_log off; 
        log_not_found off; 
    }

    location /static/ {
        alias /opt/watertracker/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location /media/ {
        alias /opt/watertracker/media/;
        expires 1y;
        add_header Cache-Control "public";
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/watertracker/watertracker.sock;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable Nginx site
ln -sf /etc/nginx/sites-available/watertracker /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Configure firewall
echo "Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx Full'
ufw --force enable

# Start and enable services
echo "Starting services..."
systemctl daemon-reload
systemctl start watertracker.socket
systemctl enable watertracker.socket
systemctl enable watertracker.service
systemctl restart nginx
systemctl enable nginx

echo "=========================================="
echo "Deployment setup completed!"
echo "=========================================="
echo ""
echo "IMPORTANT: Manual steps remaining:"
echo "1. Run 'mysql_secure_installation' to secure MySQL"
echo "2. Update .env file with actual secret key and passwords"
echo "3. Update Nginx config with your actual domain/IP"
echo "4. Create Django superuser: cd /opt/watertracker/app/watertracker && sudo -u watertracker ../venv/bin/python manage.py createsuperuser"
echo "5. Test the application: curl http://your-server-ip"
echo ""
echo "Service status commands:"
echo "- Check Gunicorn: systemctl status watertracker"
echo "- Check Nginx: systemctl status nginx"
echo "- Check MySQL: systemctl status mysql"
echo ""
echo "Log files:"
echo "- Gunicorn: journalctl -u watertracker"
echo "- Nginx: /var/log/nginx/error.log"
echo "- MySQL: /var/log/mysql/error.log"