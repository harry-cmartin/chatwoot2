class CreateSavedPrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :saved_prompts, id: :uuid do |t|
      t.text :nome, null: false
      t.text :conteudo, null: false
      t.integer :user_id, null: false
      t.timestamps
    end

    add_index :saved_prompts, :user_id
    add_foreign_key :saved_prompts, :users, column: :user_id
  end
end