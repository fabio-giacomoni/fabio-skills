#!/usr/bin/env bash
# Rigenera gli ZIP delle skill in dist/, uno per ogni cartella di skills/.
#
# Uso:
#   ./build.sh            ricrea dist/<skill>.zip per tutte le skill
#   ./build.sh --check    non scrive nulla: esce con errore se dist/ non è aggiornata
#
# Richiede il comando `zip` (su Debian/Ubuntu: sudo apt install zip).
#
# Gli ZIP sono riproducibili: se una skill non cambia, il suo ZIP resta identico
# byte per byte e git non lo segnala come modificato.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="$ROOT/skills"
DIST="$ROOT/dist"

CHECK=0
case "${1:-}" in
  "") ;;
  --check) CHECK=1 ;;
  *) echo "Uso: ./build.sh [--check]" >&2; exit 2 ;;
esac

if ! command -v zip >/dev/null 2>&1; then
  echo "ERRORE  manca il comando 'zip' (su Debian/Ubuntu: sudo apt install zip)" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Legge un campo dal frontmatter (il blocco tra le prime due righe ---).
frontmatter_field() {
  awk '/^---[[:space:]]*$/ { n++; next } n == 1' "$1" \
    | sed -n "s/^$2:[[:space:]]*//p" | head -n 1 | tr -d '\r' | sed 's/[[:space:]]*$//'
}

# Controlla che la skill sia caricabile; stampa gli errori e ritorna 1 se ce ne sono.
validate() {
  local dir="$1" name="$2" file="$1/SKILL.md" ok=0 skill_name description

  if [[ ! -f "$file" ]]; then
    echo "ERRORE  $name: manca SKILL.md"
    return 1
  fi
  if [[ "$(head -n 1 "$file" | tr -d '\r')" != "---" ]]; then
    echo "ERRORE  $name: SKILL.md non inizia con il frontmatter tra ---"
    return 1
  fi

  skill_name="$(frontmatter_field "$file" name)"
  description="$(frontmatter_field "$file" description)"

  if [[ "$skill_name" != "$name" ]]; then
    echo "ERRORE  $name: name '$skill_name' diverso dal nome della cartella"; ok=1
  fi
  if [[ ! "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || (( ${#skill_name} > 64 )); then
    echo "ERRORE  $name: name deve avere solo minuscole, numeri e trattini (max 64)"; ok=1
  fi
  if [[ -z "$description" ]]; then
    echo "ERRORE  $name: description mancante"; ok=1
  elif (( ${#description} > 1024 )); then
    echo "ERRORE  $name: description troppo lunga (${#description} > 1024)"; ok=1
  fi
  return "$ok"
}

# Crea lo ZIP in $2, con la cartella della skill come radice.
build_zip() {
  local dir="$1" out="$2" name stage
  name="$(basename "$dir")"
  stage="$TMP/stage-$name"

  mkdir -p "$stage"
  cp -R "$dir" "$stage/$name"
  # Data e permessi fissi, così lo ZIP non cambia se non cambiano i file.
  find "$stage/$name" -type f -exec chmod 644 {} + -exec touch -t 198001010000 {} +

  (
    cd "$stage"
    find "$name" -type f ! -name '.*' | LC_ALL=C sort | TZ=UTC zip -X -q -@ "$out"
  )
}

failed=0
found=0
expected=" "

for dir in "$SKILLS"/*/; do
  [[ -d "$dir" ]] || continue
  dir="${dir%/}"
  name="$(basename "$dir")"
  found=1

  if ! validate "$dir" "$name"; then
    failed=1
    continue
  fi

  target="$DIST/$name.zip"
  expected+="$name.zip "
  build_zip "$dir" "$TMP/$name.zip"

  if [[ -f "$target" ]] && cmp -s "$TMP/$name.zip" "$target"; then
    echo "ok          dist/$name.zip"
  elif (( CHECK )); then
    failed=1
    echo "DA RIFARE   dist/$name.zip"
  else
    mkdir -p "$DIST"
    cp "$TMP/$name.zip" "$target"
    echo "aggiornato  dist/$name.zip"
  fi
done

if (( ! found )); then
  echo "Nessuna skill trovata in skills/"
  exit 1
fi

# ZIP rimasti in dist/ per skill che non esistono più.
for stale in "$DIST"/*.zip; do
  [[ -f "$stale" ]] || continue
  base="$(basename "$stale")"
  [[ "$expected" == *" $base "* ]] && continue
  if (( CHECK )); then
    failed=1
    echo "DI TROPPO   dist/$base"
  elif (( ! failed )); then
    rm "$stale"
    echo "rimosso     dist/$base"
  fi
done

if (( failed )); then
  echo
  if (( CHECK )); then
    echo "dist/ non è aggiornata: lancia ./build.sh"
  else
    echo "Build non riuscito."
  fi
  exit 1
fi
