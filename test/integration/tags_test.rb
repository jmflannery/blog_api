require 'test_helper'

class TagsTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  let(:current_user) { FactoryGirl.create(:user) }
  let(:token) { FactoryGirl.create(:token, user: current_user, expires_at: 1.year.from_now) }

  describe "Create" do

    let(:attrs) {{ name: 'ruby' }}

    describe 'given a valid Token' do

      before do
        token.generate_key!
        token.save
        header 'Authorization', "Bearer #{token.key}"
      end

      describe "given valid attributes" do

        it "creates a tag" do
          post 'tags', tag: attrs
          last_response.status.must_equal 201
          response = JSON.parse(last_response.body)['tag']
          response['id'].to_s.must_match /\d+/
          response['name'].must_equal 'ruby'
        end
      end

      describe "given invalid attributes" do

        describe "invalid blank tag name" do
          let(:invalid_attrs) {{ name: '' }}

          it "returns 400 Bad Request with a hash of errors" do
            post 'tags', tag: invalid_attrs
            last_response.status.must_equal 400
            response = JSON.parse(last_response.body)['errors']
            response['name'].must_equal ["can't be blank"]
          end
        end

        describe "invalid duplicate tag name" do
          let(:tag1) { Tag.create({ name: 'javascript' }) }

          let(:invalid_attrs) {{ name: 'javascript' }}

          it "returns 400 Bad Request with a hash of errors" do
            tag1
            post 'tags', tag: invalid_attrs
            last_response.status.must_equal 400
            response = JSON.parse(last_response.body)['errors']
            response['name'].must_equal ["has already been taken"]
          end
        end
      end
    end

    describe 'given an invalid Token' do
      before do
        header 'Authorization', "Bearer wrong"
      end

      it 'returns 401 Unauthorized' do
        post 'tags', tag: attrs
        last_response.status.must_equal 401
      end
    end
  end
end
