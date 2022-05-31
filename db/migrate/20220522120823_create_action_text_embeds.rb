class CreateActionTextEmbeds < ActiveRecord::Migration[6.1]
  def change
    create_table :action_text_embeds do |t|
      t.string :url
      t.jsonb :fields

      t.timestamps
    end
  end
end
