# Complete Free Deployment Guide - AWS Free Tier

Deploy your Daily Water Intake Tracker **completely FREE** using AWS Free Tier resources.

## 🎯 Free Tier Overview

**What's FREE for 12 months:**
- EC2 t2.micro instance (750 hours/month)
- 30 GB EBS storage
- 15 GB data transfer out
- Route 53 DNS queries (first 1 billion)

**What stays FREE forever:**
- 1 million Lambda requests/month
- DynamoDB (25 GB storage)
- CloudFront CDN (1 TB transfer)

**⚠️ IMPORTANT - Free Tier Instance Types (Updated 2025):**

**Current AWS Free Tier Eligibility** (as of October 2025):
- ✅ **Check the "Free tier eligible" label** - AWS has updated their free tier
- ✅ **t3.micro** - Now appears as FREE in many regions (newer offering)
- ✅ **t2.micro** - Traditional free tier instance (may vary by region)

**⚠️ CRITICAL: Always look for the "Free tier eligible" label in the AWS console!**

**If you see t3.micro as "Free tier eligible":**
- ✅ **USE t3.micro** - It's actually better performance than t2.micro
- ✅ **1 GB memory, better CPU performance**
- ✅ **Still within AWS Free Tier limits**

**Only use instances that show "Free tier eligible" label in YOUR specific region!**

## 📋 Prerequisites Checklist

- [ ] AWS Account (requires credit card for verification, but won't be charged)
- [ ] Domain name (optional - use free services like Freenom or use IP address)
- [ ] Basic computer with internet connection
- [ ] SSH client (built into Windows 10+, Mac, Linux)

## 🆕 **AWS Free Tier Update (2025)**

**Important Notice:** AWS has updated their Free Tier program in 2025. The specific instance types that are "free tier eligible" may vary by:

- **Region** (different AWS regions may have different offerings)
- **Account type** (new vs. existing accounts)
- **Date** (AWS periodically updates free tier offerings)

**What to do:**
1. ✅ **Always trust the AWS console** - look for "Free tier eligible" label
2. ✅ **t3.micro is often the new free tier offering** (better than t2.micro)
3. ✅ **Choose whatever shows "Free tier eligible" in YOUR region**
4. ❌ **Never assume** - always verify in the console

## 🚀 Step 1: Create AWS Account (FREE)

1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Fill in details:
   - Account name: `daily-water-tracker`
   - Email: Your email
   - Password: Strong password
4. Select "Personal" account type
5. Fill billing information (required for verification, won't be charged)
6. Verify phone number
7. Choose "Basic Support - Free"

## 🖥️ Step 2: Launch FREE EC2 Instance

### 2.1 Navigate to EC2
1. Sign in to AWS Console
2. Search for "EC2" in the search bar
3. Click "EC2" service

### 2.2 Launch Instance
1. Click "Launch Instance"
2. Configure as follows:

**Name:** `daily-water-intake-server`

**Application and OS Images:**
- Select "Ubuntu"
- Choose "Ubuntu Server 24.04 LTS (HVM), SSD Volume Type" 
- AMI ID: ami-02d26659fd82cf299 (64-bit x86)
- Architecture: 64-bit (x86)

**Instance Type:**
- Look for the **"Free tier eligible"** label next to the instance type
- ✅ **If t3.micro shows "Free tier eligible"** → Select t3.micro (better performance!)
- ✅ **If t2.micro shows "Free tier eligible"** → Select t2.micro (traditional choice)
- ❌ **NEVER select instances without "Free tier eligible" label**

**Current Status (October 2025):** Many users report t3.micro as free tier eligible

**Key Pair:**
1. Click "Create new key pair"
2. Name: `water-tracker-key`
3. Type: RSA
4. Format: .pem (for Mac/Linux) or .ppk (for Windows PuTTY)
5. Click "Create key pair"
6. **IMPORTANT:** Save the downloaded key file securely

**Network Settings:**
1. Click "Edit"
2. Create security group:
   - Name: `water-tracker-sg`
   - Description: `Security group for water tracker`
3. Security group rules:
   ```
   Type     Protocol  Port  Source      Description
   SSH      TCP       22    My IP       SSH access
   HTTP     TCP       80    0.0.0.0/0   Web traffic
   HTTPS    TCP       443   0.0.0.0/0   Secure web
   MySQL    TCP       3306  My IP       Database
   ```

**Configure Storage:**
- Size: 20 GiB (within free tier - up to 30 GB free)
- Volume type: gp2 (General Purpose SSD)
- Delete on termination: Checked

**Advanced Details:**
- Leave all as default

3. Click "Launch Instance"

### 2.3 Get Instance Details
1. Wait for instance to be "Running" (takes 2-3 minutes)
2. Select your instance
3. Copy the "Public IPv4 address" - you'll need this!

## 🔗 Step 3: Connect to Your Server

### Option A: Using PuTTY (Windows - .ppk files) 🔧

**If you downloaded a `.ppk` file, use PuTTY:**

#### 3.1 Download and Install PuTTY
1. Go to: https://www.putty.org/
2. Download and install PuTTY (takes 2 minutes)

#### 3.2 Configure PuTTY Connection
1. **Open PuTTY application**

2. **Basic Connection Settings:**
   - **Host Name:** `ubuntu@YOUR-EC2-IP-ADDRESS`
   - **Port:** `22`
   - **Connection type:** `SSH`

3. **Configure SSH Authentication:**
   - In left panel: **Connection → SSH → Auth → Credentials**
   - **Private key file:** Click "Browse..."
   - Navigate to: `Documents\water-tracker-key.ppk`
   - Select your key file

4. **Save Session (Recommended):**
   - Return to **Session** tab
   - **Saved Sessions:** `water-tracker-server`
   - Click **"Save"**

5. **Connect:**
   - Click **"Open"**
   - **Security Alert:** Click "Accept" (first time only)

#### 📋 PuTTY Quick Setup Checklist
- [ ] PuTTY installed
- [ ] Host Name: `ubuntu@YOUR-EC2-IP-ADDRESS`
- [ ] Port: 22, SSH selected
- [ ] Key file: `Documents\water-tracker-key.ppk`
- [ ] Session saved for future use
- [ ] Successfully connected

#### 3.3 Successful Connection
You'll see:
```
Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 6.8.0-1014-aws x86_64)
ubuntu@ip-172-31-xx-xx:~$ 
```

### Option B: Using Command Line (.pem files)

#### For Windows (PowerShell):
```powershell
# Open PowerShell/Command Prompt
# Navigate to where you saved the key file
cd Documents
# Set proper permissions
icacls water-tracker-key.pem /inheritance:r /grant:r %username%:R
# Connect to server (replace YOUR-IP with actual IP)
ssh -i water-tracker-key.pem ubuntu@YOUR-IP-ADDRESS
```

#### For Mac/Linux:
```bash
# Open Terminal
# Navigate to where you saved the key file
cd ~/Downloads
# Set proper permissions
chmod 400 water-tracker-key.pem
# Connect to server (replace YOUR-IP with actual IP)
ssh -i water-tracker-key.pem ubuntu@YOUR-IP-ADDRESS
```

**First connection will ask:** `Are you sure you want to continue connecting?`
- Type: `yes` and press Enter

### 🆘 Common Connection Issues

#### **PuTTY "Unable to open connection"**
- ✅ Check your EC2 IP address is correct
- ✅ Verify security group allows SSH (port 22)
- ✅ Ensure EC2 instance is "Running"

#### **"Server refused our key"**
- ✅ Make sure you selected the correct `.ppk` file
- ✅ Verify username is `ubuntu@` not just the IP

#### **Command Line "Permission denied"**
- ✅ Wrong key file path or permissions
- ✅ Check username is `ubuntu`

## 🛠️ Step 4: Deploy Application (One Command!)

Once connected to your server, run this single command:

```bash
curl -O https://raw.githubusercontent.com/Anamikamahi18/daily-water-intake/main/deployment/deploy.sh && chmod +x deploy.sh && sudo ./deploy.sh
```

This will automatically:
- Update the system (Ubuntu 24.04 LTS)
- Install Python, MySQL, Nginx
- Download your application
- Set up the database
- Configure all services

**Wait time:** 5-10 minutes depending on internet speed.

**Note:** The deployment script works perfectly with Ubuntu 24.04 LTS!

## 🔧 Step 5: Post-Deployment Configuration

### 5.1 Secure MySQL Database
```bash
sudo mysql_secure_installation
```

Answer the prompts:
- `Validate password component?` → **N** (or Y if you want strong passwords)
- `Remove anonymous users?` → **Y**
- `Disallow root login remotely?` → **Y**
- `Remove test database?` → **Y**
- `Reload privilege tables?` → **Y**

### 5.2 Set Database Password
```bash
# Set a secure password for watertracker user
sudo mysql -e "ALTER USER 'watertracker'@'localhost' IDENTIFIED BY 'MySecurePassword123!';"
```

### 5.3 Configure Environment Variables
```bash
sudo nano /opt/watertracker/app/.env
```

Update these values:
```env
DEBUG=False
SECRET_KEY=MyVeryLongAndSecureSecretKeyWith50Characters12345
DB_NAME=daily_water_intake
DB_USER=watertracker
DB_PASSWORD=MySecurePassword123!
DB_HOST=localhost
DB_PORT=3306
ALLOWED_HOSTS=YOUR-EC2-IP-ADDRESS,localhost,127.0.0.1
```

**To save in nano:**
- Press `Ctrl + X`
- Press `Y`
- Press `Enter`

### 5.4 Update Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/watertracker
```

Find this line:
```
server_name your-domain.com your-ec2-public-ip;
```

Replace with your actual IP:
```
server_name YOUR-EC2-IP-ADDRESS;
```

Save and exit (Ctrl+X, Y, Enter).

### 5.5 Create Django Admin User
```bash
cd /opt/watertracker/app/watertracker
sudo -u watertracker ../venv/bin/python manage.py createsuperuser
```

Fill in:
- Username: `admin`
- Email: `your-email@example.com`
- Password: Choose a strong password

### 5.6 Start All Services
```bash
sudo systemctl daemon-reload
sudo systemctl start watertracker.socket
sudo systemctl enable watertracker.socket
sudo systemctl enable watertracker.service
sudo systemctl restart nginx
sudo systemctl enable nginx
```

## 🌐 Step 6: Access Your Application

### 6.1 Open in Browser
Navigate to: `http://YOUR-EC2-IP-ADDRESS`

You should see your Daily Water Intake Tracker!

### 6.2 Admin Access
Navigate to: `http://YOUR-EC2-IP-ADDRESS/admin`
- Login with the superuser account you created

## 💰 Step 7: Keep It FREE - Monitoring Usage

### 7.1 Set Up Billing Alerts
1. Go to AWS Console → Billing & Cost Management
2. Click "Billing preferences"
3. Enable "Receive Billing Alerts"
4. Go to CloudWatch → Alarms
5. Create alarm for billing > $1

### 7.2 Monitor Free Tier Usage
1. AWS Console → Billing & Cost Management
2. Click "Free Tier"
3. Monitor your usage regularly

### 7.3 Free Tier Limits to Watch
- **EC2 Hours:** 750/month (24/7 for one t2.micro)
- **EBS Storage:** 30 GB
- **Data Transfer:** 15 GB out per month
- **Elastic IP:** Free when attached to running instance

## 🔒 Step 8: Security Best Practices (FREE)

### 8.1 Enable AWS Security Features
```bash
# Update system regularly
sudo apt update && sudo apt upgrade -y

# Enable firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
```

### 8.2 Regular Backups
```bash
# Create backup (run weekly)
sudo /opt/watertracker/app/deployment/backup.sh
```

### 8.3 Monitor Application Health
```bash
# Check system health
sudo /opt/watertracker/app/deployment/monitor.sh
```

## 🆓 Step 9: Free Domain Name (Optional)

### Option 1: Free Domain Services
- **Freenom:** Free .tk, .ml, .ga domains
- **No-IP:** Free subdomain service
- **DuckDNS:** Free dynamic DNS

### Option 2: Use IP Address
- Continue using your EC2 IP address
- Bookmark: `http://YOUR-EC2-IP-ADDRESS`

## 🔄 Step 10: Maintenance Commands

### Update Application
```bash
sudo /opt/watertracker/app/deployment/update.sh
```

### View Logs
```bash
# Application logs
sudo journalctl -u watertracker -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### Restart Services
```bash
sudo systemctl restart watertracker
sudo systemctl restart nginx
```

## 🆘 Troubleshooting

### Application Not Loading?
```bash
# Check service status
sudo systemctl status watertracker
sudo systemctl status nginx

# Restart if needed
sudo systemctl restart watertracker nginx
```

### Database Issues?
```bash
# Test database connection
mysql -u watertracker -p daily_water_intake
```

### Static Files Not Loading?
```bash
cd /opt/watertracker/app/watertracker
sudo -u watertracker ../venv/bin/python manage.py collectstatic --noinput
sudo systemctl restart nginx
```

### Can't Connect via SSH?
1. Check security group allows SSH (port 22) from your IP
2. Verify key file permissions
3. Ensure you're using the correct IP address

## 💡 Cost Optimization Tips

### Keep Costs at $0
1. **Use only t2.micro instances** (free tier)
2. **Stop instance when not needed** (saves hours)
3. **Delete snapshots/AMIs** you don't need
4. **Monitor data transfer** (15 GB limit)
5. **Release unused Elastic IPs**

### AWS Free Tier Expiration (After 12 months)
- **Continue with free tier instance:** Will cost ~$8-12/month after free tier
- **Upgrade to larger instances:** Better performance but higher costs
- **Or migrate to other free services:**
  - Google Cloud Platform (3 months free)
  - Digital Ocean ($200 credit)
  - Oracle Cloud (always free tier)
  - Railway, Render, or Fly.io (free tiers available)

**Note:** t3.micro typically costs ~$10.50/month, t2.micro costs ~$8.50/month after free tier expires.

## 📞 Support & Resources

### Documentation
- [AWS Free Tier Guide](https://aws.amazon.com/free/)
- [Django Deployment Guide](https://docs.djangoproject.com/en/4.2/howto/deployment/)

### Free Learning Resources
- [AWS Free Training](https://aws.amazon.com/training/free/)
- [Django Documentation](https://docs.djangoproject.com/)

### Community Support
- [AWS Community Forums](https://forums.aws.amazon.com/)
- [Django Community](https://www.djangoproject.com/community/)

## ✅ Final Checklist

- [ ] AWS account created
- [ ] EC2 t2.micro instance launched (FREE)
- [ ] Application deployed successfully
- [ ] Database configured and secure
- [ ] Admin user created
- [ ] Application accessible via browser
- [ ] Billing alerts set up
- [ ] Regular backups scheduled
- [ ] Security best practices implemented

## 🎉 Congratulations!

Your Daily Water Intake Tracker is now live and completely FREE! 

**Your application URL:** `http://YOUR-EC2-IP-ADDRESS`
**Admin panel:** `http://YOUR-EC2-IP-ADDRESS/admin`

Remember to monitor your AWS usage to stay within the free tier limits!
