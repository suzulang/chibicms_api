require 'rails_helper'

RSpec.describe "Sessions", type: :request do
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
end
