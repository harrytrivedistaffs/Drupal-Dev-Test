Drupal version : 11.4.5
Site URI       : http://default
PHP binary     : /opt/cpanel/ea-php83/root/usr/bin/php
PHP config     : /opt/cpanel/ea-php83/root/etc/php.ini
PHP OS         : Linux
PHP version    : 8.3.33
Drush script   : /home/digitalscc/drupaltestv2/vendor/bin/drush.php
Drush version  : 13.7.6.0
Drush temp     : /tmp
Drush configs  : /home/digitalscc/drupaltestv2/vendor/drush/drush/drush.yml
Drupal root    : /home/digitalscc/drupaltestv2/web
Site path      : sites/default
Drupal config  : ../config/sync


$databases['default']['default'] = [
  'database' => 'cpaneluser_dbname',
  'username' => 'cpaneluser_dbuser',
  'password' => 'your-db-password',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'prefix' => '',
];


In SiteProcess.php line 214:

  The command "/home/digitalscc/drupaltestv2/vendor/bin/drush config:import --yes --uri=default" failed.

  Exit Code: 1(General error)

  Working directory:

  Output:
  ================
  +------------+---------------------------------------------------------------+-----------+
  | Collection | Config                                                        | Operation |
  +------------+---------------------------------------------------------------+-----------+
  |            | core.entity_view_display.node.localgov_subsites_page.full     | Create    |
  |            | core.entity_view_display.node.localgov_subsites_overview.full | Create    |
  |            | core.extension                                                | Update    |
  |            | metatag.metatag_defaults.node__localgov_news_article          | Update    |
  |            | staffordshire_scc.settings                                    | Update    |
  |            | system.theme.global                                           | Update    |
  |            | views.view.localgov_directory_channel                         | Update    |
  |            | views.view.localgov_news_list                                 | Update    |
  |            | block.block.staffs_homepage_news_grid                         | Update    |
  |            | views.view.localgov_news_search                               | Update    |
  |            | block.block.staffordshire_scc_localgov_news_date              | Update    |
  |            | block.block.staffordshire_scc_localgov_news_category          | Update    |
  |            | block.block.staffordshire_scc_localgov_news_search            | Update    |
  |            | gin_login.settings                                            | Update    |
  |            | shield.settings                                               | Update    |
  +------------+---------------------------------------------------------------+-----------+

   // Import the listed configuration changes?: yes.



  Error Output:
  ================
   [warning] Drush command terminated abnormally.


[digitalscc@31 drupaltestv2]$ ^C
[digitalscc@31 drupaltestv2]$ ^C
