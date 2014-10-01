<?php

$databases['default']['default'] = array(
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => '@@PASSWORD@@',
  'host' => 'localhost',
  'driver' => 'mysql',
  'port' => 3306,
  'prefix' => '',
);

// $conf['cache_backends'][] = 'sites/all/modules/contrib/memcache/memcache.inc';
// $conf['cache_default_class'] = 'MemCacheDrupal';
// $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
