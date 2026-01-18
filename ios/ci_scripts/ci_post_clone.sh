#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Build Flutter app with dart-define variables for AdMob
flutter build ios --release --no-codesign \
  --dart-define=AD_IOS_BANNER_HOME="$AD_IOS_BANNER_HOME" \
  --dart-define=AD_IOS_BANNER_PARTIDA="$AD_IOS_BANNER_PARTIDA" \
  --dart-define=AD_IOS_BANNER_PUNTUACION="$AD_IOS_BANNER_PUNTUACION" \
  --dart-define=AD_IOS_BANNER_AGREGAR_JUGADOR="$AD_IOS_BANNER_AGREGAR_JUGADOR" \
  --dart-define=AD_IOS_BANNER_EDITAR_ENTIDAD="$AD_IOS_BANNER_EDITAR_ENTIDAD" \
  --dart-define=AD_IOS_INTERSTITIAL="$AD_IOS_INTERSTITIAL" \
  --dart-define=AD_IOS_REWARDED_REVANCHA="$AD_IOS_REWARDED_REVANCHA"

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

exit 0
