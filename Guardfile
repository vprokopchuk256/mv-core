guard :rspec, cmd: 'bundle exec rspec', all_after_pass: true, failed_mode: :focus do
  watch(%r{^spec/mv/.+_spec\.rb$})
  watch(%r{^lib/mv/(.+)\.rb$})     { |m| "spec/mv/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

