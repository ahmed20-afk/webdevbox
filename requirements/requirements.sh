#!/bin/bash

# Detect OS and set package manager
package_manager=""
php_version="php"
apache_package="apache2"
nginx_package="nginx"
mariadb_package="mariadb-server"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "🔍 Detected OS: $PRETTY_NAME"

    case "$ID" in
        ubuntu|debian|linuxmint)
            package_manager="apt"
            sudo apt update
            ;;
        fedora|centos|rhel)
            package_manager="dnf"
            sudo dnf update -y
            ;;
        arch|manjaro)
            package_manager="pacman"
            sudo pacman -Syu --noconfirm
            ;;
        opensuse*|suse)
            package_manager="zypper"
            sudo zypper refresh
            ;;
        alpine)
            package_manager="apk"
            sudo apk update
            ;;
        *)
            echo "❌ Unsupported distro: $ID"
            exit 1
            ;;
    esac
else
    echo "❌ Cannot detect OS. /etc/os-release not found."
    exit 1
fi

# Ask user for web server choice
read -p "🌐 Which web server do you want to install? [apache/nginx]: " web_server
web_server=$(echo "$web_server" | tr '[:upper:]' '[:lower:]')  # normalize

# Install common packages
echo "📦 Installing dependencies..."

case "$package_manager" in
    apt)
        sudo apt install -y curl git unzip mariadb-server php php-mysql php-cli php-curl php-zip php-mbstring php-xml php-bcmath php-intl

        if [[ "$web_server" == "nginx" ]]; then
            sudo apt install -y nginx php-fpm
        else
            sudo apt install -y apache2 libapache2-mod-php
        fi

        sudo apt install -y phpmyadmin
        ;;
    
    dnf)
        sudo dnf install -y curl git unzip mariadb-server php php-mysqlnd php-cli php-common php-mbstring php-xml php-gd php-json php-fpm

        if [[ "$web_server" == "nginx" ]]; then
            sudo dnf install -y nginx
        else
            sudo dnf install -y httpd php
        fi

        sudo dnf install -y phpMyAdmin
        ;;

    pacman)
        sudo pacman -S --noconfirm curl git unzip mariadb php php-fpm php-apache

        if [[ "$web_server" == "nginx" ]]; then
            sudo pacman -S --noconfirm nginx
        else
            sudo pacman -S --noconfirm apache
        fi

        echo "⚠️ Install phpMyAdmin manually on Arch."
        ;;

    zypper)
        sudo zypper install -y curl git unzip mariadb php8 php8-mysql php8-fpm php8-mbstring php8-xml php8-bcmath php8-intl

        if [[ "$web_server" == "nginx" ]]; then
            sudo zypper install -y nginx
        else
            sudo zypper install -y apache2 apache2-mod_php8
        fi

        sudo zypper install -y phpMyAdmin
        ;;

    apk)
        sudo apk add curl git unzip mariadb php php-fpm php-mysqli php-curl php-zip php-mbstring php-xml php-bcmath php-intl

        if [[ "$web_server" == "nginx" ]]; then
            sudo apk add nginx
        else
            echo "❌ Apache is not recommended on Alpine. Only Nginx supported."
            exit 1
        fi

        echo "⚠️ phpMyAdmin needs manual setup on Alpine"
        ;;
esac

echo "✅ Installation completed!"

