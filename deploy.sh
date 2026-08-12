#!/usr/bin/env bash
#
# One-command deploy for cPanel. Run this after "Update from Remote" / git
# pull in the Git Version Control repo folder — it installs composer
# dependencies and brings the database in line with whatever config and
# code shipped in that pull.
#
# Usage:
#   bash deploy.sh
#
# If your cPanel account's default `php` isn't 8.3+, set PHP_BIN first
# (Software > MultiPHP Manager in cPanel shows the exact path, usually
# something like /opt/cpanel/ea-php83/root/usr/bin/php):
#   PHP_BIN=/opt/cpanel/ea-php83/root/usr/bin/php bash deploy.sh

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [ ! -f composer.json ]; then
  echo "deploy.sh: composer.json not found here — run this from the repo root." >&2
  exit 1
fi

PHP_BIN="${PHP_BIN:-php}"
if [ "$PHP_BIN" != "php" ]; then
  export PATH
  PATH="$(dirname "$PHP_BIN"):$PATH"
fi

PHP_VERSION="$("$PHP_BIN" -r 'echo PHP_VERSION;')"
echo "==> Using PHP $PHP_VERSION ($PHP_BIN)"
case "$PHP_VERSION" in
  8.3.*|8.4.*) ;;
  *)
    echo "    Warning: Drupal 11 wants PHP 8.3 or 8.4 — this looks off."
    echo "    Re-run as: PHP_BIN=/path/to/php8.3 bash deploy.sh"
    ;;
esac

# Fresh clones never have web/sites/default/ at all — settings.php and
# services.yml are gitignored (they hold credentials), and git doesn't
# track empty directories. Harmless to repeat on later deploys.
mkdir -p web/sites/default/files

echo
echo "==> composer install"
composer install --no-dev --optimize-autoloader

echo
echo "==> drush deploy (config import + database updates + cache rebuild)"
vendor/bin/drush deploy -y

echo
echo "==> Done."
