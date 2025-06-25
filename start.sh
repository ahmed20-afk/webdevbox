#!/bin/bash


# Start services
echo "🚀 Starting services..."
sudo systemctl start nginx
sudo systemctl start "$php_service"
sudo systemctl start mariadb
