def with_env(vars)
  original = {}
  
  vars.each do |k, v|
    original[k] = ENV[k]
    ENV[k] = v
  end

  yield

  vars.each do |k, _v|
    ENV[k] = original[k]
  end
end
