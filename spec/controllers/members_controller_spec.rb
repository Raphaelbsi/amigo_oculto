require 'rails_helper'

RSpec.describe MembersController, type: :controller do
    include Devise::Test::ControllerHelpers

    before(:each) do
      # request.env["HTTP_ACCEPT"] = 'application/json'
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_user = FactoryBot.create(:user)
      sign_in @current_user
    end

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #show" do
        context "member don't exists" do
          it "Redirects to root" do
            get :show, params: {id: 0}
            expect(response).to redirect_to('/')
          end
        end
    end

    describe "POST #create" do
        before(:each) do
          @member_attributes = attributes_for(:member, user: @current_user)
          post :create, params: {member: @member_attributes}
        end
    
        it "Redirect to new member" do
          expect(response).to have_http_status(302)
          expect(response).to redirect_to("/members/#{member.last.id}")
        end
    
        it "Create member with right attributes" do
          expect(member.last.name).to eql(@member_attributes[:name])
          expect(member.last.email).to eql(@member_attributes[:email])
          expect(member.last.campaign_id).to eql(@member_attributes[:campaign_id])
          expect(member.last.open).to eql(@member_attributes[:open])
          expect(member.last.token).to eql(@member_attributes[:token])
        end
    end

  describe "DELETE #destroy" do
      before(:each) do
        request.env["HTTP_ACCEPT"] = 'application/json'
      end

      context "Delete for members" do
        it "returns http success" do
          member = create(:member, user: @current_user)
          delete :destroy, params: {id: member.id}
          expect(response).to have_http_status(:success)
        end
      end


      describe "PUT #update" do
        before(:each) do
          @new_member_attributes = attributes_for(:member)
          request.env["HTTP_ACCEPT"] = 'application/json'
        end
      context "Update for Members" do
        before(:each) do
          member = create(:member, user: @current_user)
          put :update, params: {id: member.id, member: @new_member_attributes}
        end
      end

    end
  end
end
