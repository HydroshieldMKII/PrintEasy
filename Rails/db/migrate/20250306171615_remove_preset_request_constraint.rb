class RemovePresetRequestConstraint < ActiveRecord::Migration[8.0]
  def change
    remove_index :preset_requests, name: :index_preset_requests_uniqueness
  end
end
