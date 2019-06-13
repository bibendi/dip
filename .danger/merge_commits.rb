# frozen_string_literal: true

# Check for merge commits
if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
  warn "Please rebase to get rid of the merge commits in this PR"
end
