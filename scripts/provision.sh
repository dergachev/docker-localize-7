#!/bin/bash

cd /drupal

echo "Running sqlq" 
drush sqlq "UPDATE block SET theme='bartik' WHERE theme='bluecheese'"
drush vset theme_default bartik

# Disable poor man's cron
# drush vset cron_safe_threshold 999999999
# disabling cron DOESN'T SEEM TO WORK (why?!?), so workaround:
drush vset l10n_cron_stats 0
drush vset l10n_community_stats_enabled 0

# change this from sites/default/files/tmp
drush vset file_temporary_path /tmp

# According to SebCorin, this will be added to settings.php
# https://www.drupal.org/node/1985800#comment-7802723
drush vset og_7000_access_field_default_value FALSE

# otherwise the bluecheese theme sticks around, for some reason
drush cc all
