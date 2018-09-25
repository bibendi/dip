# frozen_string_literal: true

shared_context "replace environment vars", env: true do
  around(:each) do |ex|
    original = {}

    env.each do |k, v|
      original[k] = ENV[k]
      ENV[k] = v
    end

    ex.run

    env.each do |k, _v|
      ENV[k] = original[k]
    end
  end
end
