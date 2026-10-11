#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
command -v flutter >/dev/null 2>&1 || { echo 'Flutter SDK não encontrado. Instale Flutter stable antes de continuar.' >&2; exit 1; }

# Flutter pode actualizar templates Web ao criar wrappers. Preserve os ficheiros
# PWA da marca para que a configuração de cache própria não seja substituída.
BACKUP_DIR="$(mktemp -d)"
trap 'rm -rf "$BACKUP_DIR"' EXIT
cp -R web "$BACKUP_DIR/web"
flutter create --platforms=android,ios,web --project-name=ea_language_hub --org=mz.ealanguagehub .
cp -R "$BACKUP_DIR/web/." web/
python3 scripts/configure_platforms.py
flutter pub get
dart run flutter_launcher_icons

echo 'Plataformas e ícones preparados. Execute: flutter run -d chrome (ou um dispositivo Android).'
