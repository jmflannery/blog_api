# This migration comes from toke (originally 20130822225749)
class CreateTokeUsers < ActiveRecord::Migration
  def change
    create_table :toke_users do |t|
      t.string :email, index: true
      t.string :password_digest

      t.timestamps
    end
  end
end