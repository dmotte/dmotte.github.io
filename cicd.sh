#!/bin/bash

set -e

# Ensure that some variables are defined
: "${MISC_SCRIPTS_DIR:?}"

cd "$(dirname "$0")"

readonly username=${1:?} out_txt=${2:?} out_html=${3:?}

################################################################################

data=$(bash "$MISC_SCRIPTS_DIR/github-get-all-repos.sh" "users/$username" \
    '.archived == false and .fork == false' \
    '.name, .description, .homepage, .topics')
echo "$data" | tr -d '\r' > "$out_txt"

################################################################################

:> "$out_html" # Empty file

tee -a "$out_html" << EOF
<h1>$username</h1>
TODO first part
EOF

while read -r name; do
    read -r description
    read -r homepage
    read -r _topics

    echo "TODO name: $name"
    echo "TODO description: $description"
    echo "TODO homepage: $homepage"
done < "$out_txt" | tee -a "$out_html"

tee -a "$out_html" << EOF
TODO last part
EOF

################################################################################

[ -z "$(git status -s)" ] || {
    echo 'There are some uncommitted changes' >&2
    git diff
    exit 1
}
