require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create(email: "test@example.com", password: "password123", password_confirmation: "password123") }
  it "is valid with valid attributes" do
    post = Post.new(title: "My Post", content: "This is the content of my post", user: user)
    expect(post).to be_valid
  end
end
