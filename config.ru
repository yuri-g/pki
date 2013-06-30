require 'rubygems'
require 'bundler'
require 'sqlite3'


Bundler.require

db = SQLite3::Database.new "./db/certificates.db"

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS  certificates (
    ID INTEGER PRIMARY KEY NOT NULL,
    UUID CHAR(36),
    BODY TEXT
  );
SQL

require './main.rb'
AuthorityApp.set :db, db
run AuthorityApp