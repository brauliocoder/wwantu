class CreateFavs < ActiveRecord::Migration[6.1]
  def change
    create_table :favs do |t|
      t.integer :user_id
      t.string :imdb_id

      t.timestamps
    end
  end
end
