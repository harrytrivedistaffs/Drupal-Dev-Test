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



[digitalscc@31 drupaltestv2]$ php -d memory_limit=1G vendor/bin/drush config:import -y --uri=default

# Support bash to support `source` with fallback on $0 if this does not run with bash
# https://stackoverflow.com/a/35006505/6512
selfArg="$BASH_SOURCE"
if [ -z "$selfArg" ]; then
    selfArg="$0"
fi

self=$(realpath "$selfArg" 2> /dev/null)
if [ -z "$self" ]; then
    self="$selfArg"
fi

dir=$(cd "${self%[/\\]*}" > /dev/null; cd '../drush/drush' && pwd)

if [ -d /proc/cygdrive ]; then
    case $(which php) in
        $(readlink -n /proc/cygdrive)/*)
            # We are in Cygwin using Windows php, so the path must be translated
            dir=$(cygpath -m "$dir");
            ;;
    esac
fi

export COMPOSER_RUNTIME_BIN_DIR="$(cd "${self%[/\\]*}" > /dev/null; pwd)"

# If bash is sourcing this file, we have to source the target as well
bashSource="$BASH_SOURCE"
if [ -n "$bashSource" ]; then
    if [ "$bashSource" != "$0" ]; then
        source "${dir}/drush" "$@"
        return
    fi
fi

exec "${dir}/drush" "$@"
[digitalscc@31 drupaltestv2]$ vendor/bin/drush cache:rebuild
 [success] Cache rebuild complete.


(async function pollUntilOk(url, delayMs = 2500, maxAttempts = 30) {
  for (let i = 1; i <= maxAttempts; i++) {
    try {
      const res = await fetch(url, { credentials: 'include', cache: 'no-store' });
      console.log(`Attempt ${i}: HTTP ${res.status}`);
      if (res.ok) {
        console.log('Loaded successfully — navigating now.');
        location.href = url;
        return;
      }
    } catch (e) {
      console.log(`Attempt ${i}: request failed`, e);
    }
    await new Promise(r => setTimeout(r, delayMs));
  }
  console.warn(`Gave up after ${maxAttempts} attempts.`);
})('https://sccdefault.digitalstaffordshire.info/YOUR-PATH-HERE');
