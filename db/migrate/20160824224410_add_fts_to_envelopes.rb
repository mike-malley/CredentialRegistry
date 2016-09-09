class AddFtsToEnvelopes < ActiveRecord::Migration
  def change
    change_table(:envelopes) do |t|
      t.text :fts_tsearch
      t.text :fts_trigram
    end
  end
end
