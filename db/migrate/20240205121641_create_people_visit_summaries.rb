class CreatePeopleVisitSummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :people_visit_summaries do |t|
      t.references :visit_summary, null: false
      t.references :person, null: false

      t.timestamps
    end

    add_foreign_key :people_visit_summaries, :visit_summaries, on_delete: :cascade
    add_foreign_key :people_visit_summaries, :people, on_delete: :cascade
  end
end
