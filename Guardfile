# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Uncomment and set this to only include directories you want to watch
#
# directories %(app lib config test spec feature)

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rsspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separetly)
#  * 'just' rspec: 'rspec'
guard :rspec, cmd: 'bundle exec rspec', all_after_pass: true, failed_mode: :focus do
  watch(%r{^spec/mv/.+_spec\.rb$})
  watch(%r{^lib/mv/(.+)\.rb$})     { |m| "spec/mv/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
