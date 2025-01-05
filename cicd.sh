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

# TODO link to GH profile page

tee -a "$out_html" << EOF
<!doctype html>
<html>
  <head>
    <title>$username's projects</title>

    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="icon" href="favicon.svg" />

    <link
      rel="stylesheet"
      type="text/css"
      href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css"
    />

    <style type="text/css">
      /* Generated using the Customizer on https://bulma.io/ */
      :root {
        --bulma-primary-h: 215deg;
        --bulma-primary-s: 100%;
        --bulma-primary-l: 50%;
        --bulma-link-h: 215deg;
        --bulma-link-s: 100%;
        --bulma-link-l: 50%;
      }
    </style>
  </head>

  <body>
    <section class="section">
      <div class="container">
        <h1 class="title">$username</h1>

        <div class="block">
          This is the list of all my <strong>projects</strong>.
        </div>

        <div class="grid is-col-min-12">
EOF

while read -r name; do
    read -r description
    read -r homepage
    read -r topics

    emoji=$(echo "$description" | cut -d' ' -f1)
    desc_without_emoji=$(echo "$description" | cut -d' ' -f2-)

    footer_items=()
    if [ -n "$homepage" ]; then
        footer_items+=("<a href=\"$homepage\" class=\"card-footer-item\">&#x1F30D; Homepage</a>")
    fi
    footer_items+=("<a href=\"https://github.com/$username/$name\" class=\"card-footer-item\">&#x1F4C1; Repo</a>")

    # We don't actually use the topics in the HTML, but it's good to have them
    # stored in the text file
    : "$topics"

    echo '          <div class="cell">'
    echo '            <div class="card">'
    echo '              <div class="card-content">'
    echo '                <div class="content">'
    echo '                  <p class="title is-4">'
    echo "                    $emoji $name"
    echo '                  </p>'
    echo '                  <p>'
    echo "                    $desc_without_emoji"
    echo '                  </p>'
    echo '                </div>'
    echo '              </div>'
    echo '              <footer class="card-footer">'
    for i in "${footer_items[@]}"; do echo "                $i"; done
    echo '              </footer>'
    echo '            </div>'
    echo '          </div>'
done < "$out_txt" | tee -a "$out_html"

tee -a "$out_html" << EOF
        </div>
      </div>
    </section>
  </body>
</html>
EOF

################################################################################

[ -z "$(git status -s)" ] || {
    echo 'There are some uncommitted changes' >&2
    git diff
    exit 1
}
