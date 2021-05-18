class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.date :published
      t.integer :score
      t.integer :category_id
      t.integer :content_id
      t.timestamps
    end
  end
end
