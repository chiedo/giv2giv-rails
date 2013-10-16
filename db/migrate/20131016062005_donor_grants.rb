class DonorGrants < ActiveRecord::Migration
  def change
    create_table :donor_grants do |t|
      t.integer :charity_id
      t.integer :charity_group_id
      t.integer :donor_id
      t.string  :status
      t.timestamps
    end
  end
end
