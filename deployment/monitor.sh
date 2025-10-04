#!/bin/bash

# Monitoring script for Daily Water Intake Tracker
# Run this script to check the health of your deployment

echo "=========================================="
echo "Daily Water Intake Tracker - Health Check"
echo "=========================================="

# Check system resources
echo "System Resources:"
echo "Memory usage:"
free -h
echo ""
echo "Disk usage:"
df -h /opt/watertracker
echo ""

# Check service status
echo "Service Status:"
services=("mysql" "nginx" "watertracker")

for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "✓ $service is running"
    else
        echo "✗ $service is NOT running"
    fi
done
echo ""

# Check database connectivity
echo "Database Connectivity:"
if mysql -u watertracker -p daily_water_intake -e "SELECT 1;" &>/dev/null; then
    echo "✓ Database connection successful"
else
    echo "✗ Database connection failed"
fi
echo ""

# Check web application
echo "Web Application:"
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$response" = "200" ]; then
    echo "✓ Web application responding (HTTP $response)"
else
    echo "✗ Web application not responding (HTTP $response)"
fi
echo ""

# Check disk space
echo "Disk Space Warning:"
disk_usage=$(df /opt/watertracker | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -gt 80 ]; then
    echo "⚠ Warning: Disk usage is ${disk_usage}%"
else
    echo "✓ Disk usage is acceptable (${disk_usage}%)"
fi
echo ""

# Check log files for errors
echo "Recent Errors:"
echo "Gunicorn errors (last 10):"
journalctl -u watertracker --since "1 hour ago" --no-pager | grep -i error | tail -10
echo ""

echo "Nginx errors (last 10):"
tail -10 /var/log/nginx/error.log 2>/dev/null | grep -v "No such file"
echo ""

# Check SSL certificate expiration (if using HTTPS)
# echo "SSL Certificate:"
# if [ -f /path/to/certificate.crt ]; then
#     expiry=$(openssl x509 -enddate -noout -in /path/to/certificate.crt | cut -d= -f2)
#     echo "Certificate expires: $expiry"
# fi

echo "=========================================="
echo "Health check completed!"
echo "=========================================="