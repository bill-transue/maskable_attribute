class CreateHickwells < ActiveRecord::Migration
  def self.up
    create_table :hickwells do |t|
      t.string :foo
      t.string :bar
      t.string :baz
      t.string :qux

      t.timestamps
    end
  end
  def self.down
    drop_table :hickwells
  end
end
