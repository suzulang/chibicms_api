require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create(email: "test@example.com", password: "password123", password_confirmation: "password123") }

  describe "validations" do
    it "is valid with valid attributes" do
      post = Post.new(title: "Test Title", content: "Test Content", user: user)
      expect(post).to be_valid
    end

    it "is invalid without a title" do
      post = Post.new(content: "Test Content", user: user)
      expect(post).to be_invalid
      expect(post.errors[:title]).to include("can't be blank")
    end

    it "is invalid without content" do
      post = Post.new(title: "Test Title", user: user)
      expect(post).to be_invalid
      expect(post.errors[:content]).to include("can't be blank")
    end

    it "is invalid without a user" do
      post = Post.new(title: "Test Title", content: "Test Content")
      expect(post).to be_invalid
      expect(post.errors[:user]).to include("must exist")
    end
  end

  describe "associations" do
    it "belongs to a user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe "publishing" do
    let(:post) { Post.create(title: "Test Title", content: "Test Content", user: user) }

    it "can be published" do
      expect(post.published_at).to be_nil
      post.publish
      expect(post.published_at).not_to be_nil
    end

    it "can determine if it's published" do
      expect(post.published?).to be false
      post.publish
      expect(post.published?).to be true
    end
  end

  describe "scopes" do
    before do
      @published_post = Post.create(title: "Published", content: "Content", user: user, published_at: Time.current)
      @unpublished_post = Post.create(title: "Unpublished", content: "Content", user: user)
    end

    it "returns published posts" do
      expect(Post.published).to include(@published_post)
      expect(Post.published).not_to include(@unpublished_post)
    end

    it "returns unpublished posts" do
      expect(Post.unpublished).to include(@unpublished_post)
      expect(Post.unpublished).not_to include(@published_post)
    end
  end
end