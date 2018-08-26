require 'yaml'

def dip_config(config)
  stub_const("Dip::Config::DEFAULT_CONFIG", config)
end
