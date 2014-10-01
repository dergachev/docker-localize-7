Notes from Seb Corbin, Oct 1

```
https://localize-7.staging.devdrupal.org/

get d6, d7 database dump
makefile

https://bitbucket.org/drupalorg-infrastructure/localize.drupal.org/src
https://www.drupal.org/user/412171
seb.corbin@gmail.com


in this makefile, we dont need:
projects[og][patch][] = "https://www.drupal.org/files/1565546-41-upgrade_ogur.patch"
( but we do for now since we use an old hash of OG in makefile)

projects[potx][version] = "1.x-dev"
we should change it to 3.x-dev and see if it works; should work
otherwise it wont parse d8 files (yaml)

projects[l10n_server][download][revision] = "53c0e50fe0ef5099fc7d1065cdf0e9b26dbc5acb"
we should use latest version of the l10n_server, skip the hash from makefile

For server dependencies:
pear install Archive_Tar      #   http://pear.php.net/package/Archive_Tar

# http://cgit.drupalcode.org/infrastructure/tree/staging/snapshot_to_staging.sh#n30
# disable OG_*, l10n_server, set their schema_version to 7999
drush updb
snapshot
# restore the schema_version to original numbers, re-enable (except og_user_roles)
# enable migrate, run "drush mi --all"
```
