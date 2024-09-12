require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "POST /login" do
    let(:user) { create(:user) }
    let(:valid_credentials) { { email: user.email, password: user.password } }
  
    it "returns a success response with token and validates token content" do
      post '/login', params: { user: valid_credentials }
      expect(response).to have_http_status(:ok)
      
      response_body = JSON.parse(response.body)
      expect(response_body['token']).to be_present
  
      # 解析token
      decoded_token = JsonWebToken.decode(response_body['token'])
      expect(decoded_token).to be_a(Hash)
  
      # 获取解析后token中的user_id
      token_user_id = decoded_token['user_id']
      expect(token_user_id).to be_present
  
      # 根据email查询数据库中的用户
      db_user = User.find_by(email: user.email)
      expect(db_user).to be_present
  
      # 对比token中的user_id和数据库中的用户id
      expect(token_user_id).to eq(db_user.id)
    end
  
    it "returns an error for non-existent email" do
      post '/login', params: { user: { email: 'nonexistent@example.com', password: 'any_password' } }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include('error' => 'Email not found')
    end
  
    it "returns an error for invalid password" do
      post '/login', params: { user: { email: user.email, password: 'wrong_password' } }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to include('error' => 'Invalid password')
    end
  end
end
