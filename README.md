

- **Profile:** `localgov`
- **Default theme:** `staffordshire_scc` (`web/themes/custom/staffordshire_scc`), base theme `localgov_base`
- **Admin theme:** `gin`

## Local development (native — no Docker/DDEV)

This project runs on plain Homebrew PHP + MariaDB, not DDEV/Lando, so it's set
up the same way most cPanel/shared hosting works.

**Requirements**

- PHP 8.3 (Drupal 11 requires 8.3+; PHP 8.5 is not yet officially supported —
  install a dedicated `php@8.3` via Homebrew rather than using the system PHP)
- MariaDB (`brew install mariadb`)
- Composer 2

**One-time setup**

```bash
brew install php@8.3 mariadb
brew services start mariadb

# Create a local DB + user
/usr/local/opt/mariadb/bin/mariadb -u "$(whoami)" -e "
  CREATE DATABASE staffordshire_scc CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
  CREATE USER 'staffs_scc'@'localhost' IDENTIFIED BY 'localdev123';
  GRANT ALL PRIVILEGES ON staffordshire_scc.* TO 'staffs_scc'@'localhost';
  FLUSH PRIVILEGES;
"

# Put PHP 8.3 first on PATH for this shell, then install dependencies
export PATH="/usr/local/opt/php@8.3/bin:/usr/local/opt/php@8.3/sbin:$PATH"
composer install

# Install the site (only needed once — after that, import config as below)
bin/drush site-install localgov -y \
  --db-url=mysql://staffs_scc:localdev123@localhost/staffordshire_scc \
  --site-name="Staffordshire County Council (Demo)" \
  --account-name=admin --account-pass=admin
bin/drush config:import -y
```

**Day to day**

```bash
export PATH="/usr/local/opt/php@8.3/bin:/usr/local/opt/php@8.3/sbin:$PATH"
bin/drush runserver 127.0.0.1:8888   # local dev server
bin/drush cr                          # clear caches after code/config changes
bin/drush config:export -y            # export config changes back to config/sync
```

> PHP's default CLI `memory_limit` (128M) is too low for `site-install` —
> if you hit a memory exhaustion error, bump `memory_limit` in
> `/usr/local/etc/php/8.3/php.ini` to `512M`.

## Theme

`web/themes/custom/staffordshire_scc` is a full fork of LocalGov Drupal's
Scarfolk theme (not a subtheme sitting on top of it) — everything is editable
directly, nothing here gets clobbered by a `composer update`.

- `css/base/variables.css` — Staffordshire palette (navy/pink) via the CSS
  custom-property system `localgov_base` already provides. Change colours here
  first before reaching for new CSS.
- `css/base/staffordshire-overrides.css` — the handful of component-level
  rules that go beyond a palette swap (pill buttons, hero, footer gradient,
  services grid, "Rate this page" band, page-title band).
- `logo.svg` — placeholder mark, not the real council logo/photography (see
  "Known gaps" below).

## Content model

Real LocalGov Drupal content types are used throughout, not one-off custom
types, so everything below is editable via `/node/add` and Block Layout like
any normal Drupal site:

- **Topic pages** (`localgov_services_landing`) — the 15 "Our Services"
  categories on the homepage, plus the homepage node itself.
- **Sub-landing pages** (`localgov_services_sublanding`) and **service pages**
  (`localgov_services_page`) — the "Adult social care" drill-down is built out
  in full as a reference; the other 14 topics are single-page stubs.
- **News** (`localgov_news_article` / `localgov_newsroom`).
- Hero banner, Featured row, News row, "Rate this page" band and the footer
  social/subscribe band are Custom Blocks (`/admin/content/block`), placed via
  Block Layout (`/admin/structure/block`) — edit their HTML there, not in Twig.

## Known gaps (by design, for a demo)

- Hero background is a placeholder gradient, not licensed aerial photography —
  swap in a real image via the "Homepage hero" custom block.
- The header logo is an original placeholder mark, not the real council logo.
- Copy throughout is generic placeholder text, not the real site's content.
- Search box in the header/hero currently posts to core's `/search/node` — swap
  for whatever search backend the real deployment ends up using.

## Deploying (cPanel)

This repo excludes `/vendor`, `/web/core`, and contrib modules/themes (see
`.gitignore`) — `composer.lock` and `config/sync/` **are** committed, so a
deploy is: pull, `composer install`, then bring the database in line with the
exported config.

```bash
git pull
composer install --no-dev
bin/drush cr
bin/drush updb -y      # run any pending DB updates
bin/drush cim -y       # import config/sync onto the DB
bin/drush cr
```

That assumes shell + Composer + Drush access on the server. **If cPanel only
offers a bare Git Version Control pull with no shell/Composer access**, this
approach won't produce a working site on its own — either use cPanel's
"post-clone" deploy script (if available) to run the above, or the deploy
branch strategy needs to shift to committing `vendor/` and `web/core` directly.
Confirm which one cPanel actually gives you before the first real deploy.

`web/sites/default/settings.php` is intentionally **not** committed (it's
gitignored) — production DB credentials go directly into that file on the
server, the same as any other Drupal site.
