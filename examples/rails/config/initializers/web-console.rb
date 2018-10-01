Rails.application.configure do
  config.web_console.whitelisted_ips = '172.0.0.0/8'
end if Rails.env.development?
