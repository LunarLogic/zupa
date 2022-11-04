class CreateVisitSummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :visit_summaries do |t|
      t.references :location, null: false
      t.date :visit_date, null: false
      t.string :content, null: false
      t.string :author, null: false

      t.timestamps
    end
  end
end
