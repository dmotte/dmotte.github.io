#!/bin/bash

set -e

# This script should be run automatically by the CI/CD

# Ensure that some variables are defined
: "${MISC_SCRIPTS_DIR:?}"

cd "$(dirname "$0")"

readonly username=${1:?} out_txt=${2:?} out_html=${3:?}

################################################################################

echo "Generating $out_txt"

data=$(bash "$MISC_SCRIPTS_DIR/github-get-all-repos.sh" "users/$username" \
    '.archived == false and .fork == false' \
    '.name, .description, .homepage, .topics')
echo "$data" | tr -d '\r' > "$out_txt"

################################################################################

echo "Generating $out_html"

:> "$out_html" # Empty file

# shellcheck disable=SC2129
cat << EOF >> "$out_html"
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

    <style type="text/css">
      .card {
        display: flex;
        flex-direction: column;
        height: 100%;
      }
      .card-footer {
        margin-top: auto;
      }
    </style>
  </head>

  <body>
    <section class="section">
      <div class="container">
        <h1 class="title">$username</h1>

        <div class="block">
          &#x1F3E0; My <strong>GitHub profile</strong> page:
          <a href="https://github.com/$username">
            <strong>github.com/$username</strong>
          </a>
        </div>

        <div class="block">
          This is the list of all my <strong>projects</strong>:
        </div>

        <div class="grid is-col-min-14 is-gap-3">
EOF

while read -r name; do
    read -r description
    read -r homepage
    read -r topics

    emoji=$(echo "$description" | cut -d' ' -f1)
    desc_without_emoji=$(echo "$description" | cut -d' ' -f2-)

    footer_items=()
    [ -z "$homepage" ] ||
        footer_items+=("<a href=\"$homepage\" class=\"card-footer-item\">&#x1F30D; Homepage</a>")
    footer_items+=("<a href=\"https://github.com/$username/$name\" class=\"card-footer-item\">&#x1F4C1; Repo</a>")

    # We don't actually use the topics in the HTML, but it's good to have them
    # stored in the text file
    : "$topics"

    echo '          <div class="cell">'
    echo '            <div class="card">'
    echo '              <div class="card-content">'
    echo '                <div class="content">'
    echo "                  <p class=\"title is-4\">$emoji $name</p>"
    echo "                  <p>$desc_without_emoji</p>"
    echo '                </div>'
    echo '              </div>'
    echo '              <footer class="card-footer">'
    for i in "${footer_items[@]}"; do echo "                $i"; done
    echo '              </footer>'
    echo '            </div>'
    echo '          </div>'
done < "$out_txt" >> "$out_html"

cat << EOF >> "$out_html"
        </div>

        <div class="block has-text-centered">
          This page was <strong>automatically generated</strong> by a
          <a
            href="https://github.com/dmotte/dmotte.github.io/blob/main/cicd.sh"
            target="_blank"
            ><strong>custom script</strong></a
          >.
        </div>
      </div>
    </section>
  </body>
</html>
EOF

echo "Formatting $out_html"

npx prettier -w "$out_html"

################################################################################

[ -z "$(git status -s)" ] || {
    echo 'There are some uncommitted changes' >&2
    git diff
    exit 1
}
