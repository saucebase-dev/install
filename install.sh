#!/bin/sh
# Saucebase bootstrap installer — https://install.saucebase.dev
#
# curl -fsSL https://install.saucebase.dev | bash -s -- my-app
#
# Ensures PHP + Composer (via php.new), installs the global `saucebase` CLI,
# then runs `saucebase new`. The only global tools it touches are PHP and Composer.

set -e

# php.new one-liners are kept in sync with the CLI's own prerequisite hints:
# packages/installer/src/Console/Commands/NewCommand.php -> displayPrerequisiteHints()

if command -v php >/dev/null 2>&1 && command -v composer >/dev/null 2>&1; then
    echo "PHP and Composer already present — skipping php.new."
else
    echo "Installing PHP and Composer via php.new..."
    case "$(uname -s)" in
        Darwin) /bin/bash -c "$(curl -fsSL https://php.new/install/mac)" ;;
        *)      /bin/bash -c "$(curl -fsSL https://php.new/install/linux)" ;;
    esac

    # ponytail: php.new (Herd Lite) installs into ~/.config/herd-lite/bin and only
    # edits shell rc files, which this piped non-interactive shell won't reload.
    # This is the calibration knob — update the path if php.new changes its install dir.
    if [ -d "$HOME/.config/herd-lite/bin" ]; then
        export PATH="$HOME/.config/herd-lite/bin:$PATH"
    fi
fi

echo "Installing the Saucebase CLI..."
composer global require saucebase/installer

# Make `saucebase` callable in this session (composer's global bin dir is not
# necessarily on PATH yet).
COMPOSER_BIN="$(composer global config bin-dir --absolute 2>/dev/null)"
if [ -n "$COMPOSER_BIN" ]; then
    export PATH="$COMPOSER_BIN:$PATH"
fi


# Piped through `curl | bash`, stdin is the script itself — by now exhausted,
# so prompts would silently fall back to defaults instead of asking. Redirect
# from the controlling terminal so `saucebase new` stays interactive.
exec saucebase new "$@" < /dev/tty
