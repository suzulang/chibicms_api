require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "POST /users" do
    it "creates a user" do
      post '/users', params: { user: { email: 'test@example.com', password: 'password', password_confirmation: 'password' } }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['email']).to eq('test@example.com')
    end

    it "returns an error when passwords do not match" do
      post '/users', params: { user: { email: 'test@example.com', password: 'password', password_confirmation: 'wrong_password' } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['password_confirmation']).to include("doesn't match Password")
    end
  end

  describe "POST /login" do
    before do
      User.create(email: 'test@example.com', password: 'password', password_confirmation: 'password')
    end

    it "logs in a user with correct credentials" do
      post '/login', params: { user: { email: 'test@example.com', password: 'password' } }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('token')
    end

    it "returns an error with incorrect email" do
      post '/login', params: { user: { email: 'wrong@example.com', password: 'password' } }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Email not found')
    end

    it "returns an error with incorrect password" do
      post '/login', params: { user: { email: 'test@example.com', password: 'wrong_password' } }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['error']).to eq('Invalid password')
    end
  end

  describe "POST /users/change_password" do
    let(:user) { User.create(email: 'test@example.com', password: 'old_password', password_confirmation: 'old_password') }

    before do
      user
    end

    it "updates the user's password with valid parameters" do
      post '/users/change_password', params: { email: user.email, current_password: 'old_password', new_password: 'new_password', new_password_confirmation: 'new_password' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Password successfully updated')
    end

    it "does not update the password when current password is incorrect" do
      post '/users/change_password', params: { email: user.email, current_password: 'wrong_password', new_password: 'new_password', new_password_confirmation: 'new_password' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Invalid current password')
    end

    it "does not update the password when new password and confirmation do not match" do
      post '/users/change_password', params: { email: user.email, current_password: 'old_password', new_password: 'new_password', new_password_confirmation: 'wrong_confirmation' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq("Password confirmation doesn't match Password")
    end

    it "does not update the password when new password is too short" do
      post '/users/change_password', params: { email: user.email, current_password: 'old_password', new_password: 'short', new_password_confirmation: 'short' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to include('Password is too short (minimum is 6 characters)')
    end
  end
end