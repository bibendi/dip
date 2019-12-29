# frozen_string_literal: true

Pry.config.history.should_save = true
Pry.config.history.file = "#{__dir__}/tmp/.pry_history"
