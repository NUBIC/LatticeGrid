# -*- coding: utf-8 -*-
#
# Rename era_comons_name column to era_commons_name so that it reads properly
class RenameEraComonsNameColumn < ActiveRecord::Migration
  def up
    rename_column :investigators, :era_comons_name, :era_commons_name
    remove_index :investigators, name: 'by_era_comons_name_unique'
    add_index(:investigators, [:era_commons_name], name: 'by_era_commons_name_unique', unique: true)
  end

  def down
    rename_column :investigators, :era_commons_name, :era_comons_name
    remove_index :investigators, name: 'by_era_commons_name_unique'
    add_index(:investigators, [:era_comons_name], name: 'by_era_comons_name_unique', unique: true)
  end
end
