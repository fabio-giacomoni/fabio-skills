#!/usr/bin/env bash
# Rigenera gli ZIP delle skill in dist/, uno per ogni cartella di skills/.
#
# La versione è nel file VERSION (es. 1.2.0) e corrisponde al tag git v1.2.0.
# In ogni skill viene scritto un manifest.json con versione e tag, che finisce
# anche dentro lo ZIP. Il tag è anche nel nome dello ZIP (dist/<skill>-v1.2.0.zip).
#
# Uso:
#   ./build.sh                    ricrea dist/<skill>-<tag>.zip per tutte le skill
#   ./build.sh --check            non scrive nulla: esce con errore se dist/ non è aggiornata
#   ./build.sh --release <vers>   aggiorna VERSION e ricrea gli ZIP con la nuova versione
#
# <vers> è un numero (es. 1.2.0) oppure patch, minor o major, che aumentano
# la cifra corrispondente della versione attuale.
#
# Lo script non esegue mai comandi git che modificano il repository: alla fine
# stampa i comandi per fare commit, creare il tag e pubblicare.
#
# Richiede il comando `zip` (su Debian/Ubuntu: sudo apt install zip).
#
# Gli ZIP sono riproducibili: se una skill non cambia, il suo ZIP resta identico
# byte per byte e git non lo segnala come modificato.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="$ROOT/skills"
DIST="$ROOT/dist"
REPO_URL="https://github.com/fabio-giacomoni/fabio-skills"

usage() {
  echo "Uso: ./build.sh [--check | --release <1.2.3|patch|minor|major>]" >&2
  exit 2
}

CHECK=0
RELEASE=""
case "${1:-}" in
  "") (( $# == 0 )) || usage ;;
  --check) (( $# == 1 )) || usage; CHECK=1 ;;
  --release) (( $# == 2 )) && [[ -n "$2" ]] || usage; RELEASE="$2" ;;
  --release=*) (( $# == 1 )) && [[ -n "${1#*=}" ]] || usage; RELEASE="${1#*=}" ;;
  *) usage ;;
esac

if ! command -v zip >/dev/null 2>&1; then
  echo "ERRORE  manca il comando 'zip' (su Debian/Ubuntu: sudo apt install zip)" >&2
  exit 1
fi

if [[ ! -f "$ROOT/VERSION" ]]; then
  echo "ERRORE  manca il file VERSION" >&2
  exit 1
fi
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERRORE  VERSION deve essere nel formato 1.2.3 (trovato: '$VERSION')" >&2
  exit 1
fi

# Con --release la versione da costruire è quella nuova; VERSION viene
# riscritto solo a build riuscito.
if [[ -n "$RELEASE" ]]; then
  IFS=. read -r major minor patch <<< "$VERSION"
  case "$RELEASE" in
    major) VERSION="$((major + 1)).0.0" ;;
    minor) VERSION="$major.$((minor + 1)).0" ;;
    patch) VERSION="$major.$minor.$((patch + 1))" ;;
    *)
      VERSION="${RELEASE#v}"
      if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "ERRORE  versione non valida: '$RELEASE' (usa 1.2.3, patch, minor o major)" >&2
        exit 1
      fi
      ;;
  esac
  if git -C "$ROOT" rev-parse -q --verify "refs/tags/v$VERSION" >/dev/null 2>&1; then
    echo "ERRORE  il tag v$VERSION esiste già: scegli una versione più alta" >&2
    exit 1
  fi
fi
TAG="v$VERSION"

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

# Stampa il manifest.json della skill $1.
manifest() {
  cat <<EOF
{
  "name": "$1",
  "version": "$VERSION",
  "tag": "$TAG",
  "repository": "$REPO_URL",
  "updates": "$REPO_URL/tags"
}
EOF
}

# Crea lo ZIP in $2, con la cartella della skill come radice.
build_zip() {
  local dir="$1" out="$2" name stage
  name="$(basename "$dir")"
  stage="$TMP/stage-$name"

  mkdir -p "$stage"
  cp -R "$dir" "$stage/$name"
  manifest "$name" > "$stage/$name/manifest.json"
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

  manifest "$name" > "$TMP/$name.manifest.json"
  if [[ -f "$dir/manifest.json" ]] && cmp -s "$TMP/$name.manifest.json" "$dir/manifest.json"; then
    :
  elif (( CHECK )); then
    failed=1
    echo "DA RIFARE   skills/$name/manifest.json"
  else
    cp "$TMP/$name.manifest.json" "$dir/manifest.json"
    echo "aggiornato  skills/$name/manifest.json"
  fi

  zipname="$name-$TAG.zip"
  target="$DIST/$zipname"
  expected+="$zipname "
  build_zip "$dir" "$TMP/$name.zip"

  if [[ -f "$target" ]] && cmp -s "$TMP/$name.zip" "$target"; then
    echo "ok          dist/$zipname"
  elif (( CHECK )); then
    failed=1
    echo "DA RIFARE   dist/$zipname"
  else
    mkdir -p "$DIST"
    cp "$TMP/$name.zip" "$target"
    echo "aggiornato  dist/$zipname"
  fi
done

if (( ! found )); then
  echo "Nessuna skill trovata in skills/"
  exit 1
fi

# ZIP rimasti in dist/ di versioni precedenti o di skill che non esistono più.
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

# Colori solo se l'output è un terminale (e NO_COLOR non è impostata).
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  HI=$'\033[1;33m' CMD=$'\033[1;36m' OFF=$'\033[0m'
else
  HI="" CMD="" OFF=""
fi

# Stampa in evidenza i comandi git per pubblicare la versione corrente.
publish_steps() {
  echo "${HI}Per pubblicarla fai commit di tutto, crea il tag $TAG e fai il push:${OFF}"
  echo "${CMD}  git add -A && git commit -m \"Versione $VERSION\"${OFF}"
  echo "${CMD}  git tag $TAG && git push && git push origin $TAG${OFF}"
}

echo
if (( CHECK )); then
  echo "dist/ è aggiornata alla versione $VERSION."
elif [[ -n "$RELEASE" ]]; then
  echo "$VERSION" > "$ROOT/VERSION"
  echo "${HI}VERSION aggiornato a $VERSION, dist/ rigenerata.${OFF}"
  publish_steps
elif git -C "$ROOT" rev-parse -q --verify "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "${HI}Versione $VERSION. Attenzione: il tag $TAG esiste già.${OFF}"
  echo "Se hai modificato le skill, passa a una nuova versione con ./build.sh --release <versione>"
else
  echo "Versione $VERSION pronta."
  publish_steps
fi
