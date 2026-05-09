---
name: release
description: |
  Guides through the full gem release process — bump version, update CHANGELOG,
  tag, push to RubyGems, and create GitHub Release.
  Use when user asks to release a new version, cut a release, or similar.
allowed-tools: Bash
---

# Gem Release Process

## Overview

The release process for the `dip` gem involves:

1. Bump version in `lib/dip/version.rb`
2. Add new section in `CHANGELOG.md`
3. Commit and push changes to `master`
4. Create and push a git tag `vX.Y.Z`
5. CI handles the rest (push to RubyGems via Trusted Publishing + GitHub Release)

## Prerequisites

- Trusted Publisher must be configured on RubyGems.org:
  - Go to `https://rubygems.org/gems/dip/settings`
  - Add a Trusted Publisher for:
    - Repository: `bibendi/dip`
    - Workflow: `release.yml`
    - Environment: *(leave empty)*
- You must have push access to the repository
- The CI must be green on `master` before releasing (recommended)

## Step-by-step

### 1. Determine new version

Look at current version in `lib/dip/version.rb`. Follow [SemVer](https://semver.org/).

### 2. Update version file

Edit `lib/dip/version.rb` and update the `VERSION` constant:

```ruby
module Dip
  VERSION = "X.Y.Z"
end
```

### 3. Update CHANGELOG

Edit `CHANGELOG.md` and add a new section at the top (after `# Changelog`):

```markdown
## [X.Y.Z] - YYYY-MM-DD

- Description of change [#123]
```

Use the format `## [X.Y.Z] - YYYY-MM-DD` with no `v` prefix.
Prefix breaking changes with `**BREAKING**`.

### 4. Commit

```bash
git add lib/dip/version.rb CHANGELOG.md
git commit -m "chore: bump version to X.Y.Z"
```

### 5. Push to master

```bash
git push origin master
```

### 6. Tag and push the tag

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

### 7. CI does the rest

Pushing the `vX.Y.Z` tag triggers `.github/workflows/release.yml` which:

1. Builds the gem and pushes to RubyGems via `rubygems/release-gem` action (Trusted Publishing — no API keys needed)
2. `bundle exec rake release` runs under the hood — skips tag creation since it already exists (`already_tagged?` guard)
3. Extracts changelog section via `scripts/release_notes.sh`
4. Creates a GitHub Release with the changelog as notes and `.gem` as asset

## Troubleshooting

- **`rake release` fails with "not clean"**: Ensure all changes are committed before pushing the tag
- **Trusted Publishing fails**: Verify the publisher is correctly configured on rubygems.org and the workflow name matches exactly `release.yml`
- **Tag already exists**: If you need to re-release, delete the tag locally and remotely first (`git tag -d vX.Y.Z && git push origin :refs/tags/vX.Y.Z`)
