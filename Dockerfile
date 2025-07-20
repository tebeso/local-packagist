FROM composer:2

RUN apk add --no-cache inotify-tools bash

COPY generator/generate.php /generate.php
COPY generator/watcher.sh /watcher.sh

CMD ["bash", "/watcher.sh"]
