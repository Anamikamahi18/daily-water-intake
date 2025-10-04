# AWS EC2 Deployment Guide

This guide provides step-by-step instructions to deploy the Daily Water Intake Tracker on AWS EC2 with Gunicorn, Nginx, and MySQL.

## Architecture Overview

```
Internet → AWS Load Balancer → EC2 Instance (Ubuntu 22.04)
                                ├── Nginx (Reverse Proxy)
                                ├── Gunicorn (WSGI Server)
                                ├── Django Application
                                └── MySQL Database
```

## Prerequisites

- AWS Account with EC2 access
- Domain name (optional but recommended)
- Basic knowledge of Linux commands
- SSH client (PuTTY for Windows, Terminal for Mac/Linux)

## Step 1: Launch EC2 Instance

### 1.1 Create EC2 Instance
1. Log into AWS Console
2. Navigate to EC2 Dashboard
3. Click "Launch Instance"
4. Configure instance:
   - **Name**: `daily-water-intake-server`
   - **AMI**: Ubuntu Server 22.04 LTS (Free Tier Eligible)
   - **Instance Type**: t2.micro (Free Tier) or t3.small (Recommended)
   - **Key Pair**: Create new or use existing
   - **Security Group**: Create new with the following rules:

### 1.2 Security Group Rules
```
Type            Protocol    Port Range    Source          Description
SSH             TCP         22            Your IP         SSH access
HTTP            TCP         80            0.0.0.0/0       Web traffic
HTTPS           TCP         443           0.0.0.0/0       Secure web traffic
MySQL/Aurora    TCP         3306          Security Group  Database access
```

### 1.3 Storage Configuration
- **Root Volume**: 20 GB (minimum)
- **Type**: gp3 (General Purpose SSD)

## Step 2: Connect to EC2 Instance

```bash
# Replace with your key file and instance IP
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

## Step 3: Server Setup

### 3.1 Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2 Run Deployment Script
```bash
# Download and run the deployment script
curl -O https://raw.githubusercontent.com/Anamikamahi18/daily-water-intake/main/deployment/deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

### 3.3 Manual Configuration Steps

After running the script, complete these manual steps:

#### A. Secure MySQL Installation
```bash
sudo mysql_secure_installation
```
- Set root password
- Remove anonymous users
- Disallow root login remotely
- Remove test database
- Reload privilege tables

#### B. Configure Environment Variables
```bash
sudo nano /opt/watertracker/app/.env
```

Update the following values:
```env
DEBUG=False
SECRET_KEY=your-super-secret-key-here-50-characters-long
DB_NAME=daily_water_intake
DB_USER=watertracker
DB_PASSWORD=your-secure-database-password
DB_HOST=localhost
DB_PORT=3306
ALLOWED_HOSTS=your-domain.com,your-ec2-public-ip,localhost
```

#### C. Update Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/watertracker
```

Replace placeholders:
- `your-domain.com` with your actual domain
- `your-ec2-public-ip` with your EC2 instance's public IP

#### D. Create Django Superuser
```bash
cd /opt/watertracker/app/watertracker
sudo -u watertracker ../venv/bin/python manage.py createsuperuser
```

#### E. Start Services
```bash
sudo systemctl daemon-reload
sudo systemctl start watertracker.socket
sudo systemctl enable watertracker.socket
sudo systemctl enable watertracker.service
sudo systemctl restart nginx
sudo systemctl enable nginx
```

## Step 4: Domain Configuration (Optional)

### 4.1 Point Domain to EC2
1. Go to your domain registrar's DNS settings
2. Create an A record pointing to your EC2 public IP:
   ```
   Type: A
   Name: @ (or www)
   Value: your-ec2-public-ip
   TTL: 300
   ```

### 4.2 Update Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/watertracker
```

Update the `server_name` directive:
```nginx
server_name your-domain.com www.your-domain.com;
```

Restart Nginx:
```bash
sudo systemctl restart nginx
```

## Step 5: SSL Certificate Setup (Let's Encrypt)

### 5.1 Install Certbot
```bash
sudo apt install certbot python3-certbot-nginx -y
```

### 5.2 Obtain SSL Certificate
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

### 5.3 Auto-renewal Setup
```bash
sudo crontab -e
```

Add this line:
```bash
0 12 * * * /usr/bin/certbot renew --quiet
```

## Step 6: Testing and Verification

### 6.1 Test Application
```bash
# Test HTTP response
curl -I http://your-domain.com

# Test HTTPS response (if SSL configured)
curl -I https://your-domain.com

# Check service status
sudo systemctl status watertracker
sudo systemctl status nginx
sudo systemctl status mysql
```

### 6.2 Monitor Logs
```bash
# Gunicorn logs
sudo journalctl -u watertracker -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# MySQL logs
sudo tail -f /var/log/mysql/error.log
```

## Step 7: Maintenance and Updates

### 7.1 Application Updates
```bash
cd /opt/watertracker/app
sudo -u watertracker git pull origin main
sudo /opt/watertracker/app/deployment/update.sh
```

### 7.2 Database Backups
```bash
# Run backup script
sudo /opt/watertracker/app/deployment/backup.sh

# Schedule daily backups
sudo crontab -e
# Add: 0 2 * * * /opt/watertracker/app/deployment/backup.sh
```

### 7.3 Health Monitoring
```bash
# Run health check
sudo /opt/watertracker/app/deployment/monitor.sh

# Schedule hourly monitoring
sudo crontab -e
# Add: 0 * * * * /opt/watertracker/app/deployment/monitor.sh >> /var/log/health-check.log
```

## Step 8: Performance Optimization

### 8.1 Gunicorn Workers
For production, adjust workers based on CPU cores:
```bash
sudo nano /etc/systemd/system/watertracker.service
```

Update the workers line:
```bash
--workers $((2 * $(nproc) + 1))
```

### 8.2 Nginx Optimization
```bash
sudo nano /etc/nginx/nginx.conf
```

Add in the `http` block:
```nginx
# Gzip compression
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_comp_level 6;
gzip_types text/plain text/css application/javascript text/xml application/xml application/json;

# File caching
open_file_cache max=1000 inactive=20s;
open_file_cache_valid 30s;
open_file_cache_min_uses 2;
open_file_cache_errors on;
```

### 8.3 MySQL Optimization
```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

Add optimizations:
```ini
[mysqld]
innodb_buffer_pool_size = 128M
innodb_log_file_size = 32M
max_connections = 100
query_cache_type = 1
query_cache_size = 16M
```

## Troubleshooting

### Common Issues

#### 1. Application Not Loading
```bash
# Check Gunicorn status
sudo systemctl status watertracker

# Check Nginx status
sudo systemctl status nginx

# Check if socket file exists
ls -la /run/watertracker/
```

#### 2. Database Connection Errors
```bash
# Test database connection
mysql -u watertracker -p daily_water_intake

# Check MySQL status
sudo systemctl status mysql

# Review Django logs
sudo journalctl -u watertracker | grep -i database
```

#### 3. Static Files Not Loading
```bash
# Recollect static files
cd /opt/watertracker/app/watertracker
sudo -u watertracker ../venv/bin/python manage.py collectstatic --noinput

# Check static directory permissions
ls -la /opt/watertracker/static/
```

#### 4. Permission Issues
```bash
# Fix application permissions
sudo chown -R watertracker:watertracker /opt/watertracker/

# Fix static files permissions
sudo chown -R watertracker:www-data /opt/watertracker/static/
sudo chmod -R 755 /opt/watertracker/static/
```

## Security Checklist

- [ ] SSH key-based authentication (disable password auth)
- [ ] Firewall configured (UFW enabled)
- [ ] SSL certificate installed and auto-renewing
- [ ] Database user has limited privileges
- [ ] Secret key is secure and environment-specific
- [ ] Debug mode disabled in production
- [ ] Regular security updates scheduled
- [ ] Backup strategy implemented
- [ ] Monitoring and logging configured

## Cost Optimization

### AWS Cost Management
1. **Instance Sizing**: Start with t2.micro (free tier) or t3.small
2. **Reserved Instances**: For long-term usage (1-3 years)
3. **Spot Instances**: For development/testing environments
4. **EBS Optimization**: Use gp3 volumes for better cost/performance

### Monitoring Costs
- Set up AWS CloudWatch billing alerts
- Use AWS Cost Explorer to track usage
- Consider AWS Budgets for cost control

## Scaling Considerations

### Vertical Scaling
- Upgrade to larger instance types as needed
- Monitor CPU, memory, and disk usage

### Horizontal Scaling
- Use Application Load Balancer
- Deploy multiple EC2 instances
- Consider RDS for managed database
- Implement session storage (Redis/Memcached)

## Support and Resources

- **Django Documentation**: https://docs.djangoproject.com/
- **Gunicorn Documentation**: https://docs.gunicorn.org/
- **Nginx Documentation**: https://nginx.org/en/docs/
- **AWS EC2 Documentation**: https://docs.aws.amazon.com/ec2/
- **MySQL Documentation**: https://dev.mysql.com/doc/

## Conclusion

Your Daily Water Intake Tracker is now deployed on AWS EC2 with:
- ✅ High-performance Gunicorn WSGI server
- ✅ Nginx reverse proxy with static file serving
- ✅ MySQL database with proper security
- ✅ SSL encryption (if domain configured)
- ✅ Automated backups and monitoring
- ✅ Production-ready configuration

For questions or issues, refer to the troubleshooting section or check the application logs.