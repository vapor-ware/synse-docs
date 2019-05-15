---
hero: Localization 
---

Synse Server supports localization/internationalization via Python's
[gettext](https://docs.python.org/3/library/gettext.html) and
[Babel](http://babel.pocoo.org/en/latest/index.html) libraries.

The language setting can be configured in the server [configuration](../user/configuration.md)
file, or by environment variable.

```
docker run -d -p 5000:5000 -e LANGUAGE=en_US vaporio/synse-server
```

The translation files are bundled with the Synse Server python package via `setup.py` configuration.
Prior to being bundled with a release, they must be generated or updated. This is up to the
developer or translator.

## Creating a new translation

When a new translation is to be added to Synse Server, there are a few steps that
should occur. For these examples, we will assume that we are adding translations
for French, whose `locale code` is `fr_FR`.

1. Make sure that the extracted localizable messages are up to date. To do this,
   the ``.pot`` file should be updated.

    ```shell
    pybabel extract \
        -o synse_server/locale/synse_server.pot \
        --project="Synse Server" \
        --copyright-holder="Vapor IO" \
        synse_server
    ```

2. Create a new translations catalog for the new translation language.
    
    ```shell
    pybabel init \
        -D synse_server \
        -i synse_server/locale/synse_server.pot \
        -d synse_server/locale \
        -l fr_FR
    ```

## Updating existing translations

Translations for a given language (other than the default language, English) will need
to be kept up-to-date manually.

To make it easier to extract, update, and compile translations, a `tox` environment was
created, as well as a Makefile target to reference it.

```shell
# via tox
tox -e i18n

# via make
make i18n
``` 

See the project's `tox.ini` configuration for more details.