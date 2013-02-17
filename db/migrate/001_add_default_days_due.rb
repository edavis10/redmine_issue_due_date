class AddDefaultDaysDue < ActiveRecord::Migration
  def self.up
    add_column :projects, :default_days_due, :integer
  end

  def self.down
    remove_column :projects, :default_days_due
  end
end
