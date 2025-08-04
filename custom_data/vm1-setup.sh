#!/bin/bash
apt-get update
apt-get install -y nginx

# Create health endpoints
mkdir -p /var/www/html/admin/health
mkdir -p /var/www/html/api

# Create health check responses
echo "VM1 Health OK" > /var/www/html/health
echo "VM1 Admin Health OK" > /var/www/html/admin/health/index.html

# Create a simple API endpoint
cat > /var/www/html/api/test.html << 'EOL'
{
  "server": "vm1",
  "status": "healthy",
  "timestamp": "$(date -Iseconds)"
}
EOL

# Configure nginx for health endpoints
cat > /etc/nginx/sites-available/default << 'EOL'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /health {
        add_header Content-Type text/plain;
        return 200 "VM1 Health OK\n";
    }

    location /admin/health {
        add_header Content-Type text/plain;
        return 200 "VM1 Admin Health OK\n";
    }

    location /api/ {
        add_header Content-Type application/json;
        try_files $uri $uri/ =404;
    }
}
EOL

# Restart nginx
systemctl restart nginx
systemctl enable nginx

# Add server identification
echo "<h1>Server: VM1 - $(hostname)</h1>" > /var/www/html/index.html
echo "<p>Application Gateway Backend Server 1</p>" >> /var/www/html/index.html
echo "<p>Health endpoints:</p>" >> /var/www/html/index.html
echo "<ul><li><a href='/health'>/health</a></li><li><a href='/admin/health'>/admin/health</a></li></ul>" >> /var/www/html/index.html
