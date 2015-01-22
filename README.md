[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/vprokopchuk256/mv-core/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
[![Build Status](https://travis-ci.org/vprokopchuk256/mv-core.svg?branch=master)](https://travis-ci.org/vprokopchuk256/mv-core)
[![Coverage Status](https://coveralls.io/repos/vprokopchuk256/mv-core/badge.png?branch=master)](https://coveralls.io/r/vprokopchuk256/mv-core?branch=master)
[![Gem Version](https://badge.fury.io/rb/mv-core.svg)](http://badge.fury.io/rb/mv-core)

# Abbreviations

MV - Migration Validators Projects. All gems that belongs to that project are prefixed with mv-*

# Project goals

Main goal of the project is to allow developer to express database constraints in a rdms - agnostic syntax that is similiar to validators in Rails.  

# mv-core

mv-core is a set of core classes that are used everywhere across Migration Validators project gems. 

This gem is not intended to be installed directly and referenced from within the application. You should rather install appropriate driver. 

# Install

  PostgreSQL:

  ```
  gem install mv-postgresql
  ```

  MySQL:

  ```
  gem install mv-mysql
  ```

  SQLite: 

  ```
  gem install mv-sqlite
  ```
 
# Usage

  Create new table:

  ```ruby
  def change 
    create_table do |t|
      t.string :str_column, validates: { uniqueness: :true, 
                                         inclusion: { in: 1..3 }}
      t.column :column_name, :integer, validates: { exclusion: { in: [1,2,3]}}
    end
  end
  ```

  Modify existing table: 
  
  ```ruby
  def up
    change_table do |t|
      t.change :str_column, :integer, validates: { exclusion: { in: [1,2,3] }}
      t.validates :column_name, inclusion: { in: 1..3 }
    end
  end

  def down
    change_table do |t|
      t.change :str_column, :integer, validates: { exclusion: false }
      t.validates :column_name, inclusion: false
    end
  end
  ```

  Update validator definition: 

  ```ruby
  def up
    validates :table_name, :str_column, exclusion: { in: [1,2,3] }
  end

  def down
    validates :table_name, :str_column, exclusion: false
  end
  ```

 There are many ways to define desired database constraint. And those ways might vary for each RDBMS. One could define the way how constaint should be 
 defined in DB: 

  as trigger:

  ```ruby
  def up
    validates :table_name, :str_column, uniqueness: { as: :trigger }
  end

  def down
    validates :table_name, :str_column, uniqueness: { as: :index }
  end
  ```

  as check constraint:

  ```ruby
  def up
    validates :table_name, :str_column, uniqueness: { as: :check }
  end

  def down
    validates :table_name, :str_column, uniqueness: false
  end
  ```

  Also there is possibility to define when validations should occur: 

  when new record created: 

  ```ruby
  def up
    validates :table_name, :str_column, uniqueness: { on: :create }
  end

  def down
    validates :table_name, :str_column, uniqueness: false
  end
  ```

  or when existing record updated:

  ```ruby
  def up
    validates :table_name, :str_column, uniqueness: { on: :update }
  end

  def down
    validates :table_name, :str_column, uniqueness: { on: :save }
  end
  ```

  And if you need to define some custom validation you can use custom validation (version >= 2.1 is required): 

  ```ruby
  def up
    validates :table_name, :str_column, 
                      custom: { statement: 'LENGTH(TRIM({str_column})) > 10', 
                                on: :update }
  end

  def down
    validates :table_name, :str_column, custom: false
  end
  ```

  as result only values with length greater than 10 will be allowed and that condition will be implemented inside ON UPDATE trigger
  
  Almost all validations supports shorter notation (simplification) that is not compatible with ActiveRecord validation but much shorter (version >= 2.1 is required): 

  ```ruby
  def up
    validates :table_name, :str_column, uniqueness: true, presence: true
  end

  def down
    validates :table_name, :str_column, uniqueness: false, presence: false
  end
  ```

  ```ruby
  def up
    validates :table_name, :str_column, length: 1..3
  end

  def down
    validates :table_name, :str_column, length: false
  end
  ```

  ```ruby
  def up
    validates :table_name, :str_column, custom: 
                           'LENGTH(TRIM({str_column})) > 10'
  end

  def down
    validates :table_name, :str_column, custom: false
  end
  ```

  Supported validators, simplification and their properties might vary from one db driver to another. See detailed properties description in correspondent driver section.  

# Maintenance tasks

  Show all constraints on the specified tables:

  ```ruby
  bundle exec rake mv:show_constraints['table_name other_table_name']
  ```

  or show all constraints are created in migrations: 

  ```ruby
  bundle exec rake mv:show_constraints
  ```

  Remove all constraints on the specified tables:

  ```ruby
  bundle exec rake mv:delete_constraints['table_name other_table_name']
  ```

  or remove all constraints are created in migrations: 

  ```ruby
  bundle exec rake mv:delete_constraints
  ```

  Create / restore / update constraints on the specified tables: 

  ```ruby
  bundle exec rake mv:create_constraints['table_name other_table_name']
  ```

  or do it for the all tables: 

  ```ruby
  bundle exec rake mv:create_constraints
  ```

  Remove all constraints and drop `migration_validators` table: 

  ```ruby
  bundle exec rake mv:uninstall
  ```

  Restore `migrations_validators` table:

  ```ruby
  bundle exec rake mv:install
  ```

# Drivers

Currently there are drivers for MySQL, PostgreSQL and SQLite RDBMS

So - see detailed info here: 

* PostgreSQL: https://github.com/vprokopchuk256/mv-postgresql
* MySQL: https://github.com/vprokopchuk256/mv-mysql
* SQLite: https://github.com/vprokopchuk256/mv-sqlite

## Contributing to mv-core
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Valeriy Prokopchuk. See LICENSE.txt for
further details.
