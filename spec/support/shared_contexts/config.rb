# frozen_string_literal: true

shared_context "dip config", :config do
  before do
    Dip.config.to_h.merge!(config)
  end
end
