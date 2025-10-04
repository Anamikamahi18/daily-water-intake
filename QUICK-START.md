# AWS EC2 Deployment - Quick Start Guide

## 🚀 One-Command Deployment

```bash
# On your EC2 instance (Ubuntu 22.04)
curl -O https://raw.githubusercontent.com/Anamikamahi18/daily-water-intake/main/deployment/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

## 📋 Post-Deployment Checklist

### 1. Secure MySQL
```bash
sudo mysql_secure_installation
```

### 2. Configure Environment
```bash
sudo nano /opt/watertracker/app/.env
```
Update these values:
- `SECRET_KEY` - Generate a secure 50+ character key
- `DB_PASSWORD` - Set a strong database password
- `ALLOWED_HOSTS` - Add your domain and EC2 IP

### 3. Update Nginx Config
```bash
sudo nano /etc/nginx/sites-available/watertracker
```
Replace placeholders with your actual domain/IP.

### 4. Create Django Superuser
```bash
cd /opt/watertracker/app/watertracker
sudo -u watertracker ../venv/bin/python manage.py createsuperuser
```

### 5. Start Services
```bash
sudo systemctl daemon-reload
sudo systemctl start watertracker.socket
sudo systemctl enable watertracker.socket
sudo systemctl restart nginx
```

## 🔧 Maintenance Commands

### Update Application
```bash
sudo /opt/watertracker/app/deployment/update.sh
```

### Create Backup
```bash
sudo /opt/watertracker/app/deployment/backup.sh
```

### Health Check
```bash
sudo /opt/watertracker/app/deployment/monitor.sh
```

### View Logs
```bash
# Application logs
sudo journalctl -u watertracker -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log

# MySQL logs
sudo tail -f /var/log/mysql/error.log
```

## 🔒 Security Setup (Optional)

### SSL Certificate with Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

### Auto-renewal
```bash
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Service Status

Check if everything is running:
```bash
sudo systemctl status watertracker
sudo systemctl status nginx
sudo systemctl status mysql
```

## 🌐 Access Your Application

- **HTTP**: `http://your-ec2-ip/` or `http://your-domain.com/`
- **Admin**: `http://your-ec2-ip/admin/` or `http://your-domain.com/admin/`

## 🆘 Troubleshooting

### Application not loading?
```bash
sudo systemctl restart watertracker
sudo systemctl restart nginx
```

### Database connection issues?
```bash
mysql -u watertracker -p daily_water_intake
```

### Static files not loading?
```bash
cd /opt/watertracker/app/watertracker
sudo -u watertracker ../venv/bin/python manage.py collectstatic --noinput
```

## 📞 Support

For detailed instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)

For issues, check the logs and troubleshooting section in the deployment guide.