FROM composer:2

# Accept build arguments for user and group IDs
ARG USER_ID=1000
ARG GROUP_ID=1000

# Install required packages
RUN apk add --no-cache inotify-tools bash

# Create a non-root user with the specified user and group IDs
RUN addgroup -g ${GROUP_ID} packagist && \
    adduser -D -u ${USER_ID} -G packagist packagist

# Copy application files
COPY generator/generate.php /generate.php
COPY generator/watcher.sh /watcher.sh

# Create satis.json file with proper permissions
RUN touch /satis.json && \
    chmod 666 /satis.json && \
    mkdir -p /build && \
    chown -R packagist:packagist /build

# Set proper permissions for the scripts
RUN chmod +x /watcher.sh && \
    chown packagist:packagist /generate.php /watcher.sh

# Switch to the non-root user
USER packagist

CMD ["bash", "/watcher.sh"]
