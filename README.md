[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/vprokopchuk256/mv-core/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
[![Build Status](https://travis-ci.org/vprokopchuk256/mv-core.svg?branch=master)](https://travis-ci.org/vprokopchuk256/mv-core)

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
  create_table do |t|
    t.string :str_column, validates: { uniqueness: :true, 
                                       inclusion: { in: 1..3 }}
    t.column :column_name, :integer, validates: { exclusion: { in: [1,2,3]}}
  end
  ```

  Modify existing table: 
  
  ```ruby
  change_table do |t|
    t.change :str_column, :integer, validates: { exclusion: { in: [1,2,3] }}
    t.change_validates :column_name, inclusion: { in: 1..3 }
  end
  ```

  Update validator definition: 

  ```ruby
  validate_column :table_name, :str_column, :exclusion: { in: [1,2,3] }
  ```

  Remove existing validators: 

  ```ruby
  change_table do |t|
    t.change :str_column, :integer, validates: { exclusion: false }
  end
  validate_column table_name, :str_column, exclusion: false
  ```

 There are many ways to define desired database constraint. And those ways might vary for each RDBMS. One could define the way how constaint should be 
 defined in DB: 

  as trigger:

  ```ruby
  validate_column :table_name, :str_column, validates: { uniqueness: true, 
                                                         as: :trigger }
  ```

  as check constraint:

  ```ruby
  validate_column :table_name, :str_column, validates: { uniqueness: true, 
                                                         as: :check }
  ```

  Also there is possibility to define when validations should occur: 

  when new record created: 

  ```ruby
  validate_column :table_name, :str_column, validates: { uniqueness: true, 
                                                         on: :create }
  ```

  or when existing record updated:

  ```ruby
  validate_column :table_name, :str_column, validates: { uniqueness: true, 
                                                         on: :update }
  ```

  Supported validators and their properties might vary from one db driver to another. See detailed properties description in correspondent driver section.  

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

Copyright (c) 2011 Valeriy Prokopchuk. See LICENSE.txt for
further details.
