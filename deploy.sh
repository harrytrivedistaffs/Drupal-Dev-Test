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

# Seed uploaded files (images etc.) from the Deploy-Artifacts snapshot —
# but only the very first time. Once .seeded exists, never touch this
# again, or a later deploy would silently overwrite anything uploaded on
# the live site since then.
if [ -f Deploy-Artifacts/staffordshire-scc-files.zip ] && [ ! -f web/sites/default/files/.seeded ]; then
  echo "==> Seeding web/sites/default/files from Deploy-Artifacts (first run only)"
  if ! command -v unzip >/dev/null 2>&1; then
    echo "deploy.sh: unzip not found — extract Deploy-Artifacts/staffordshire-scc-files.zip into web/sites/default/ yourself." >&2
    exit 1
  fi
  unzip -oq Deploy-Artifacts/staffordshire-scc-files.zip -d web/sites/default/
  touch web/sites/default/files/.seeded
fi

echo
if command -v composer >/dev/null 2>&1; then
  echo "==> composer install"
  composer install --no-dev --optimize-autoloader
else
  echo "==> composer not found on PATH — downloading composer.phar locally instead"
  if [ ! -f composer.phar ]; then
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL -o composer.phar https://getcomposer.org/composer-stable.phar
    elif command -v wget >/dev/null 2>&1; then
      wget -q -O composer.phar https://getcomposer.org/composer-stable.phar
    else
      echo "deploy.sh: neither curl nor wget is available to download composer.phar." >&2
      echo "Download it yourself and place it at $(pwd)/composer.phar:" >&2
      echo "  https://getcomposer.org/composer-stable.phar" >&2
      exit 1
    fi
    if [ ! -s composer.phar ]; then
      echo "deploy.sh: composer.phar download failed (empty or missing file)." >&2
      echo "Check this server has outbound internet access to getcomposer.org," >&2
      echo "or download composer.phar yourself and place it at $(pwd)/composer.phar." >&2
      rm -f composer.phar
      exit 1
    fi
    chmod +x composer.phar
  fi
  echo "==> composer install"
  "$PHP_BIN" composer.phar install --no-dev --optimize-autoloader
fi

echo
echo "==> drush deploy (config import + database updates + cache rebuild)"
vendor/bin/drush deploy -y

echo
echo "==> Done."
