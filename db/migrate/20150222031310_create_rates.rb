class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.datetime :date
      t.float :dollar
      t.float :euro
      t.float :oil

      t.timestamps
    end
  end
end
