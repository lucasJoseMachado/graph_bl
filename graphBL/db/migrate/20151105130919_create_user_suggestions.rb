class CreateUserSuggestions < ActiveRecord::Migration
  def change
    create_table :user_suggestions do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :group
      t.text :suggestion

      t.timestamps null: false
    end
  end
end
