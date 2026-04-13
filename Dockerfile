# Use the official Nginx image as base
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy website files to nginx html directory
COPY index.html .
COPY styles.css .
COPY script.js .
COPY images/ ./images/

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Test nginx configuration
RUN nginx -t

# Expose port 80
EXPOSE 80

# Add labels for better container management
LABEL maintainer="Carolina Herrera Monteza <contact@carolinaherreramonteza.com>"
LABEL description="Personal website for Carolina Herrera Monteza - Senior DevOps Engineer"
LABEL version="1.0.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]