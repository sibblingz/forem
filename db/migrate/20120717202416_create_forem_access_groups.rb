class CreateForemAccessGroups < ActiveRecord::Migration
  def change
    create_table :forem_access_groups do |t|
      t.integer :forum_id
      t.integer :group_id

      t.timestamps
    end
  end
end
