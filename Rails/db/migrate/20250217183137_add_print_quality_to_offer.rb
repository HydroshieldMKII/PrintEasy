class AddPrintQualityToOffer < ActiveRecord::Migration[7.1]
  def change
    add_column :offers, :print_quality, :string
  end
end
