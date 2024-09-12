require 'rails_helper'

RSpec.describe "Posts", type: :request do
  # read
  describe "GET /posts" do
    it "returns all posts for the authenticated user" do
      user = create(:user)
      token = user.generate_jwt
      create_list(:post, 3, user: user)
      create(:post)  # 创建一个属于其他用户的帖子

      get "/posts", headers: { 'Authorization': "#{token}" }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end
  # create
  describe "POST /posts" do
    it "creates a new post for the authenticated user" do
      user = create(:user)
      token = user.generate_jwt
      post_params = { title: "测试标题", content: "测试内容" }

      expect {
        post "/posts", params: { post: post_params }, headers: { 'Authorization': "#{token}" }
      }.to change(Post, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['title']).to eq("测试标题")
      expect(json_response['content']).to eq("测试内容")
      expect(json_response['user_id']).to eq(user.id)
    end
  end

  # delete
  describe "DELETE /posts/:id" do
    it "deletes the post for the authenticated user" do
      user = create(:user)
      token = user.generate_jwt
      post = create(:post, user: user)

      expect {
        delete "/posts/#{post.id}", headers: { 'Authorization': "#{token}" }
      }.to change(Post, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns unauthorized if user tries to delete another user's post" do
      user = create(:user)
      token = user.generate_jwt
      other_user = create(:user)
      post = create(:post, user: other_user)

      expect {
        delete "/posts/#{post.id}", headers: { 'Authorization': "#{token}" }
      }.not_to change(Post, :count)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  # update
  describe "PATCH /posts/:id" do
    it "updates the post for the authenticated user" do
      user = create(:user)
      token = user.generate_jwt
      post = create(:post, user: user, title: "原标题", content: "原内容")
      update_params = { title: "更新后的标题", content: "更新后的内容" }

      patch "/posts/#{post.id}", params: { post: update_params }, headers: { 'Authorization': "#{token}" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['title']).to eq("更新后的标题")
      expect(json_response['content']).to eq("更新后的内容")
      expect(json_response['id']).to eq(post.id)
      expect(json_response['user_id']).to eq(user.id)

      # 验证数据库中的记录也被更新
      post.reload
      expect(post.title).to eq("更新后的标题")
      expect(post.content).to eq("更新后的内容")
    end

    it "returns unauthorized if user tries to update another user's post" do
      user = create(:user)
      token = user.generate_jwt
      other_user = create(:user)
      post = create(:post, user: other_user, title: "原标题", content: "原内容")
      update_params = { title: "更新后的标题", content: "更新后的内容" }

      patch "/posts/#{post.id}", params: { post: update_params }, headers: { 'Authorization': "#{token}" }

      expect(response).to have_http_status(:unauthorized)
      # 验证帖子没有被更新
      post.reload
      expect(post.title).to eq("原标题")
      expect(post.content).to eq("原内容")
    end
  end
end
