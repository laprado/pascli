#!/usr/bin/env bash
# Generates the documentation site with pasdoc 1.0 into the docs folder, from any folder.
# The site is published by the docs workflow, the generated files are not committed.
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
generate="$root/docs/generate"

if ! command -v pasdoc >/dev/null; then
  echo "pasdoc was not found, it is required to build the documentation: https://pasdoc.github.io" >&2
  exit 1
fi

# the guides, in the order of the menu
pages=(quickstart application command features testing project)

args=(
  --format=html
  --use-tipue-search
  --title=pascli
  --output "$root/docs"
  --introduction="$generate/introduction.txt"
)
for page in "${pages[@]}"; do
  args+=(--additional="$generate/$page.txt")
done

pasdoc "${args[@]}" "$root"/src/*.pas

# pasdoc lists the reference pages first: move the guides to the top and put the reference
# pages under a header, keeping the search box at the end
for file in "$root"/docs/*.html; do
  perl -0pi -e '
    s{(<ul class="nav flex-column[^>]*>)(.*?)(<li class="nav-item pt-2.*?)?</ul>}{
      my ($open, $items, $search) = ($1, $2, $3 // "");
      my (@guides, @reference);
      for my $item ($items =~ m{(<li class="nav-item">.*?</li>)}g) {
        if ($item =~ m{href="(All\w+|ClassHierarchy)\.html"}) { push @reference, $item }
        else { push @guides, $item }
      }
      $open . join("", @guides) .
        q{<li class="nav-item pt-3"><span class="nav-link px-2 py-1 fw-bold">Reference</span></li>} .
        join("", @reference) . $search . "</ul>"
    }se' "$file"
done

echo "Documentation generated in $root/docs"
