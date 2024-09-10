require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    expect(user).to be_valid
  end

  it "is not valid without an email" do
    user = User.new(
      email: nil,
      password: "password123",
      password_confirmation: "password123"
    )
    expect(user).to_not be_valid
  end
  

  it "generate a jwt token" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    token = JsonWebToken.encode(user_id: user.id)
    decoded_token = JsonWebToken.decode(token)
    expect(decoded_token["user_id"]).to eq(user.id)
  end
end
