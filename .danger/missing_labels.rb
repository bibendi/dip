# frozen_string_literal: true

# Check for labels presence (ignoring "wip" label)
non_wip_labels = github.pr_labels - %w[wip]
failure "Please add labels to this PR" if non_wip_labels.empty?
