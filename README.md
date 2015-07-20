[![Build Status](https://travis-ci.org/vprokopchuk256/mv-core.svg?branch=master)](https://travis-ci.org/vprokopchuk256/mv-core)
[![Coverage Status](https://coveralls.io/repos/vprokopchuk256/mv-core/badge.png?branch=master)](https://coveralls.io/r/vprokopchuk256/mv-core?branch=master)
[![Gem Version](https://badge.fury.io/rb/mv-core.svg)](http://badge.fury.io/rb/mv-core)

# Define validations in database and use them in model

Project ```Migration Validators``` (MV) makes it possible for RoR developer to define validations directly in db and then bubble them up to model so they available as normal ActiveModel::Validations there. And all that without code duplication.

**WARNING** Versions lower than 2.0 are not supported anymore. As results, rails v.3 or older are not supported either.

# Abbreviations

MV - Migration Validators Projects. All gems that belongs to that project are prefixed with mv-*

#Table Of Contents
* [Why Migration Validators](#why-migration-validators)
* [How It Works](#how-it-works)
* [Examples](#examples)
* [Installation](#installation)
  * [PostgreSQL](#postgresql)
  * [MySQL](#mysql)
  * [SQLite](#sqlite)
* [Integration with ActiveRecord](#integration-with-activerecord)
* [SchemaRb](#schemarb)
* [Tasks](#tasks)
* [Drivers](#drivers)
* [Version History](#version history)
* [Contributing](#contributing)

# Why `Migration Validators`

It's commonly accepted in RoR community to ignore database constraints and define data validations in ActiveModel. In most cases such approach is perfectly acceptable and allows developer to concentrate on business logic rather than on writing database - specific code.

But when your application grows significantly then possibility of the data error with such approach became more tangible. Data consistency could be violated in many ways: directly ( with db console for ex ), as result of some error in the code, by other application if database is shared.

DB constraints could help in such case. But there are several reasons why they are not widely spread in RoR: such constraints are DB - specific in most cases and their management is quite tricky.

The goal of the `Migration Validators` project is to resolve those problems and make DB constraints management straightforward

# How It Works

`Migration Validators` project uses 3 database constructs to define validations: ```trigger```, ```check constraint```, ```index```

Most of the validations could be defined in several ways: as condition inside trigger, as condition inside check constraint or as index ( for ```uniqueness```)

In most cases developer can select how and where validation should be implemented. By default most optimal way is proposed.

For example: ```uniqueness``` validation is defined as unique index by default. But developer can select other way - trigger of check constraint. Each way has own advantages and disadvantages

# Examples

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

  Update validation definition:

  ```ruby
  def up
    validates :table_name, :str_column, exclusion: { in: [1,2,3] }
  end

  def down
    validates :table_name, :str_column, exclusion: false
  end
  ```

 There are many ways to define desired database constraint. And those ways might vary for each RDBMS. One could define the way how constraint should be
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

  Supported validators, simplification and their properties might vary from one db driver to another. See detailed properties description in correspondent [driver](#drivers) section.

# Installation

`mv-core` is a set of core classes that are used everywhere across `Migration Validators` project gems.

This gem is not intended to be installed directly and referenced from within the application. You should rather install appropriate driver.

### PostgreSQL:

  ```
  gem install mv-postgresql
  ```

### MySQL:

  ```
  gem install mv-mysql
  ```

### SQLite:

  ```
  gem install mv-sqlite
  ```

# Integration With ActiveRecord

You can level up validations that are defined in DB to your model using `enforce_migration_validations` method.

Example:

migration:

```ruby
  def change
    create_table :posts do |t|
      t.string :title, presence: { message: "can't be blank", as: :trigger }
    end
  end
```

model:

```ruby
  class Post << ActiveRecord::Base
    enforce_migration_validations
  end
```

console:

```ruby
  p = Post.new(title: nil)

  p.valid?
  => false

  p.errors.full_messages
  => ["Title can't be blank"]
```

# SchemaRb

  All validations that you've defined are dumped to schema.rb automatically:

  in migration:

```ruby
  def change
    create_table :posts do |t|
      t.string :title, presence: { message: "can't be blank", as: :trigger }
    end
  end
```

in 'schema.rb':

```ruby
  validates(:posts, :title,
                    presence: { message: "can't be blank", as: :trigger})
```

# Tasks

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

## Version History

**(2.0.0)** (17 Jan, 2015)

* Completely rewritten. Migrated to Ruby 2.0 and RoR 4

**(2.1.0)** (22 Jan, 2015)

* Custom validation

**(2.2.0)** (28 Jan, 2015)

* Integration with ActiveRecord

**(2.2.1)** (20 Jul, 2015)

* Fix issue with invalid parameters number in `add_column` and `change_column` methods

## Contributing

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
