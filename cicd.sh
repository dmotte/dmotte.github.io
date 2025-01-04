#!/bin/bash

set -e

# Ensure that some variables are defined
: "${MISC_SCRIPTS_DIR:?}"

cd "$(dirname "$0")"

readonly username=${1:?} out_txt=${2:?} out_html=${3:?} description=${4:-}

data=$(bash "$MISC_SCRIPTS_DIR/github-get-all-repos.sh" "users/$username" \
    '.archived == false and .fork == false' \
    '.name, .description, .homepage, .topics')
echo "$data" | tr -d '\r' > "$out_txt"

# TODO
: "$out_html" "$description"

[ -z "$(git status -s)" ] || {
    echo 'There are some uncommitted changes' >&2
    git diff
    exit 1
}
