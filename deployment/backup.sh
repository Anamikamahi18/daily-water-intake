#!/bin/bash

# Backup script for Daily Water Intake Tracker
# Run this script regularly to backup your data

BACKUP_DIR="/opt/watertracker/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="daily_water_intake"
DB_USER="watertracker"

# Create backup directory
mkdir -p $BACKUP_DIR

echo "=========================================="
echo "Creating backup: backup_$DATE"
echo "=========================================="

# Backup database
echo "Backing up database..."
mysqldump -u $DB_USER -p $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# Backup media files
echo "Backing up media files..."
tar -czf $BACKUP_DIR/media_backup_$DATE.tar.gz -C /opt/watertracker media/

# Backup application code
echo "Backing up application code..."
tar -czf $BACKUP_DIR/app_backup_$DATE.tar.gz -C /opt/watertracker app/ --exclude=app/venv --exclude=app/.git

# Remove old backups (keep last 7 days)
echo "Cleaning up old backups..."
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

# Set proper permissions
chown -R watertracker:watertracker $BACKUP_DIR

echo "=========================================="
echo "Backup completed!"
echo "Files saved in: $BACKUP_DIR"
echo "=========================================="

# List recent backups
echo "Recent backups:"
ls -lah $BACKUP_DIR/ | grep $DATE