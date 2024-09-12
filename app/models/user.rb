class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6, too_short: "Password is too short (minimum is 6 characters)" }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?
  has_many :posts
  def generate_jwt
    JsonWebToken.encode(user_id: id)
  end
  private

  def password_required?
    new_record? || password.present?
  end
end
