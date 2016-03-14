# ARL
ARL is an ORM inspired by Active Record. ARL is a layer between your database and your application. You can use it to store your objects into the database without writing SQL queries. ORM uses metaprogramming in RUBY to build a custom SQL queries into database.

## Documentation
This version of the ARL works only with SqlLite3 databases.
In order to make it test you have to follow instruction:
  - git clone https://github.com/mexxxxx/ARL.git
  - Open terminal and run pry
  - include './lib/associatable'. This will include all necessary files.
  - There are two tables in test database cats: Cats and humans
  - Create classes Cats and Humans by inheriting SQLObjects
  - Now you can use SQLObjects methods to manipulate data in database

## Avaible SQLObjects methods
  - **`::all`**
  - **`::find`**
  - **`::insert`**
  - **`::update`**
  - **`::save`**
  - You can set assosiations:
    - **`belongs_to`**
    - **`has_one_through`**
    - **`has_many`**
