#!/bin/bash

# Deployment update script for Daily Water Intake Tracker
# Run this script to update the application after code changes

echo "=========================================="
echo "Updating Daily Water Intake Tracker..."
echo "=========================================="

# Navigate to application directory
cd /opt/watertracker/app

# Pull latest changes
echo "Pulling latest changes from repository..."
sudo -u watertracker git pull origin main

# Install/update dependencies
echo "Installing/updating Python dependencies..."
sudo -u watertracker ./venv/bin/pip install -r deployment/requirements.txt

# Run migrations
echo "Running database migrations..."
cd watertracker
sudo -u watertracker ../venv/bin/python manage.py migrate

# Collect static files
echo "Collecting static files..."
sudo -u watertracker ../venv/bin/python manage.py collectstatic --noinput

# Restart services
echo "Restarting services..."
systemctl restart watertracker
systemctl reload nginx

# Check service status
echo "Checking service status..."
systemctl status watertracker --no-pager
systemctl status nginx --no-pager

echo "=========================================="
echo "Update completed!"
echo "=========================================="

# Test the application
echo "Testing application..."
curl -I http://localhost/

echo "If you see '200 OK', the application is running successfully!"