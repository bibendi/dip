# frozen_string_literal: true

# Check that there are both app and test code changes for the main app
changed_files = CHANGED_FILES.select { |path| path =~ /^(exe|lib)/ }

if changed_files.any?
  changed_test_files = CHANGED_FILES.select { |path| path =~ /^spec/ }

  if changed_test_files.empty?
    warn "Are you sure we don't need to add/update tests for the main app?"
  end
end
