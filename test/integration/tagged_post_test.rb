require 'test_helper'

class TaggedPostTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  let(:current_user) { FactoryGirl.create(:user) }
  let(:token) { FactoryGirl.create(:token, user: current_user, expires_at: 1.year.from_now) }

  let(:tag1) { Tag.create(name: 'ruby') }
  let(:tag2) { Tag.create(name: 'javascript') }

  describe "Create" do

    let(:attrs) {{
      title: 'My Post',
      content: 'This post rocks!',
      slug: 'this-post-rocks',
    }}
    let(:tag_attrs) { [tag1.id, tag2.id] }

    describe 'given a valid Token' do

      before do
        token.generate_key!
        token.save
        header 'Authorization', "Bearer #{token.key}"
      end

      describe "given valid attributes" do

        it "creates a post with tags" do
          post 'posts', post: attrs, tags: tag_attrs
          last_response.status.must_equal 201
          response = JSON.parse(last_response.body)['post']
          response['tags'][0]['name'].must_equal 'ruby'
          response['tags'][1]['name'].must_equal 'javascript'
        end
      end
    end
  end
end
