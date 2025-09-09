class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.timestamp :clock_in
      t.timestamp :clock_out
      t.float :duration

      add_index :sleep_records, [:clock_in]
      add_index :sleep_records, [:duration]
      t.timestamps
    end
  end
end
