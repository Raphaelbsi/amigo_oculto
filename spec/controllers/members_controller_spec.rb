require 'rails_helper'

RSpec.describe MembersController, type: :controller do
    include Devise::Test::ControllerHelpers

    before(:each) do
      request.env["HTTP_ACCEPT"] = 'application/json'
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @current_user = FactoryBot.create(:user)
      sign_in @current_user
    end
    
    describe "POST #create" do
      context "User is owner of campaign" do
        before(:each) do
          @campaign = create(:campaign, user: @current_user)
          @member_attributes = attributes_for(:member)
          @member_attributes[:campaign_id] = @campaign.id
          post :create, params: { member: @member_attributes }
        end

        it "Create a new member with right attributes" do
          expect(Member.last.name).to eql(@member_attributes[:name])
          expect(Member.last.email).to eql(@member_attributes[:email])
          expect(Member.last.campaign_id).to eql(@campaign.id)
          expect(Member.last.open).to eql(@member_attributes[:open])
        end

        it "Member is associated right campaing" do
          expect(Campaign.last.members.last.name).to eql(@member_attributes[:name])
          expect(Campaign.last.members.last.email).to eql(@member_attributes[:email])
        end

        it 'return http success' do
          expect(response).to have_http_status :success
        end

        it 'Return method 200' do
          member = create(:member, campaign: @campaign)
          member_attributes = { name: member.name, email: member.email, campaign_id: member.campaign_id }
          post :create, params: { member: member_attributes }
          expect(response).to have_http_status(:success)
        end

        it 'Return method 422' do
          post :create, params: { member: {name: '', email: '', campaign_id: @campaign.id } }
          expect(response).to have_http_status(:unprocessable_entity)

        end
      end
    end

    describe 'DELETE #destroy' do
      before(:each) do
        request.env['HTTP_ACCEPT'] = 'application/json'
      end
      context 'User with permission' do
        context 'Member found' do
          before(:each) do
            @campaign = create(:campaign, user: @current_user)
            @member = create(:member, campaign: @campaign)
            delete :destroy, params: { id: @member.id }
          end
  
          it 'return http success' do
            expect(response).to have_http_status(:success)
          end
  
          it 'Member deleted' do
            expect(Member.exists?(id: @member.id)).to eql(false)
          end
  
          it 'Member removed of your campaign' do
            expect(@campaign.members.exists?(id: @member.id)).to eql(false)
          end
        end
  
      context 'Member not found' do
          it 'Redirects to root' do
            delete :destroy, params: { id: 898 }
            expect(response).to redirect_to('/')
          end
        end
      end
  
      context 'User without permission' do
        it 'return http forbidden' do
          member = create(:member)
          delete :destroy, params: { id: member.id }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    describe 'PUT #update' do
      before(:each) do
        request.env['HTTP_ACCEPT'] = 'application/json'
        @member_new_attrs = attributes_for(:member)
      end
      
      context 'User with permission' do
        before(:each) do
          @campaign = create(:campaign, user: @current_user)
        end
        context 'Member is valid' do
          before(:each) do
            @member = create(:member, campaign: @campaign)
            put :update, params: { id: @member.id, member: @member_new_attrs }
          end
  
          it 'return http success' do
            expect(response).to have_http_status(:success)
          end
          it 'Member update with datas right' do
            member_updated = Member.find(@member.id)
  
            expect(member_updated.name).to eql(@member_new_attrs[:name])
            expect(member_updated.email).to eql(@member_new_attrs[:email])
          end

        end
        context 'Member is not valid' do
          it 'return http unprocessable_entity' do
            member = create(:member, campaign: @campaign)
            put :update, params: { id: member.id, member: { name: '', email: '' } }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'User without permission' do
        it 'return http forbidden' do
          member = create(:member)
  
          put :update, params: { id: member.id, member: @member_new_attrs }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

