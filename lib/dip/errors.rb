# frozen_string_literal: true

module Dip
  Error = Class.new(StandardError)

  class VersionMismatchError < Dip::Error
  end
end
