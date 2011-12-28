class CreateHickwells < ActiveRecord::Migration
  def change
    create_table :hickwells do |t|
      t.string :foo
      t.string :bar
      t.string :baz
      t.string :qux

      t.timestamps
    end
  end
end
