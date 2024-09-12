require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    let(:valid_attributes) { attributes_for(:user) }
  
    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post '/users', params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end
  
      it "returns a success response with user data" do
        post '/users', params: { user: valid_attributes }
        expect(response).to have_http_status(:created)
        
        response_body = JSON.parse(response.body)
        expect(response_body['email']).to eq(valid_attributes[:email])
        expect(response_body['id']).to be_present
        expect(response_body['created_at']).to be_present
        expect(response_body['updated_at']).to be_present
        expect(response_body['password_digest']).to be_nil # 确保密码摘要没有被返回
      end
    end
  
    context "with invalid parameters" do
      it "does not create a new user with mismatched passwords" do
        invalid_attributes = valid_attributes.merge(password_confirmation: 'wrong_password')
        expect {
          post '/users', params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end
  
      it "returns an error response for mismatched passwords" do
        invalid_attributes = valid_attributes.merge(password_confirmation: 'wrong_password')
        post '/users', params: { user: invalid_attributes }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['password_confirmation']).to include("doesn't match Password")
      end
  
      it "does not create a new user with invalid email" do
        invalid_attributes = valid_attributes.merge(email: 'invalid_email')
        expect {
          post '/users', params: { user: invalid_attributes }
        }.not_to change(User, :count)
      end
  
      it "returns an error response for invalid email" do
        invalid_attributes = valid_attributes.merge(email: 'invalid_email')
        post '/users', params: { user: invalid_attributes }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['email']).to include("is invalid")
      end
    end
  end



  describe "POST /users/change_password" do
    let(:password) { 'correct_password' }
    let(:user) { create(:user, password: password, password_confirmation: password) }

    it "updates the user's password with valid parameters" do
      post '/users/change_password', params: { email: user.email, current_password: password, new_password: 'new_password', new_password_confirmation: 'new_password' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Password successfully updated')
    end

    it "does not update the password when current password is incorrect" do
      post '/users/change_password', params: { email: user.email, current_password: 'wrong_password', new_password: 'new_password', new_password_confirmation: 'new_password' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Invalid current password')
    end

    it "does not update the password when new password and confirmation do not match" do
      post '/users/change_password', params: { 
        email: user.email, 
        current_password: password, # 使用正确的当前密码
        new_password: 'new_password', 
        new_password_confirmation: 'wrong_confirmation' 
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq("Password confirmation doesn't match Password")
    end

    it "does not update the password when new password is too short" do
      post '/users/change_password', params: { 
        email: user.email, 
        current_password: password, # 使用正确的当前密码
        new_password: 'short', 
        new_password_confirmation: 'short' 
      }

      expect(response).to have_http_status(:unprocessable_entity)
      
      response_body = JSON.parse(response.body)
      expect(response_body['error']).to include('Password is too short (minimum is 6 characters)')
      
      
      # 然后进行断言
      expect(response_body['error']).to include('Password is too short (minimum is 6 characters)')
    end
  end
end