require 'test_helper'

class Admin::PostsTest < ActiveSupport::TestCase

  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  let(:current_user) { FactoryGirl.create(:user) }
  let(:token) { FactoryGirl.create(:token, user: current_user, expires_at: 1.year.from_now) }

  describe "Create" do

    let(:attrs) {{ title: 'My Post', content: 'This post rocks!' }}

    describe 'given a valid Token' do

      before do
        token.generate_key!
        token.save
        header 'Authorization', "Bearer #{token.key}"
      end

      describe "given valid attributes" do

        it "creates a post" do
          post 'admin/posts', post: attrs
          last_response.status.must_equal 201
          response = JSON.parse(last_response.body)['post']
          response['id'].to_s.must_match /\d+/
          response['title'].must_equal 'My Post'
          response['content'].must_equal 'This post rocks!'
        end
      end

      describe "given invalid attributes" do

        let(:invalid_attrs) {{ post: { title: '', content: 'This post rocks!' }}}

        it "returns 400 Bad Request with a hash of errors" do
          post 'admin/posts', invalid_attrs
          last_response.status.must_equal 400
          response = JSON.parse(last_response.body)['errors']
          response['title'].must_equal ["can't be blank"]
        end
      end
    end

    describe 'given an invalid Token' do
      before do
        header 'Authorization', "Bearer wrong"
      end

      it 'returns 401 Unauthorized' do
        post 'admin/posts', post: attrs
        last_response.status.must_equal 401
      end
    end
  end

  describe "Index" do

    let(:unpublished1) { FactoryGirl.create(:post) }
    let(:unpublished2) { FactoryGirl.create(:post) }
    let(:published) { FactoryGirl.create(:published_post) }
    setup { @post_ids = [unpublished1.id, unpublished2.id, published.id] }

    describe 'given a valid Token' do

      before do
        token.generate_key!
        token.save
        header 'Authorization', "Bearer #{token.key}"
      end

      it "returns all posts" do
        get 'admin/posts'
        last_response.status.must_equal 200
        posts = JSON.parse(last_response.body)['posts']
        assert_equal 3, posts.size
        ids = posts.map { |p| p['id'] }
        ids.must_include unpublished1.id
        ids.must_include unpublished2.id
        ids.must_include published.id
      end
    end

    describe 'given an invalid Token' do
      before do
        header 'Authorization', "Bearer wrong"
      end

      it 'returns only published posts' do
        get 'admin/posts'
        last_response.status.must_equal 200
        posts = JSON.parse(last_response.body)['posts']
        assert_equal 1, posts.size
        ids = posts.map { |p| p['id'] }
        ids.must_include published.id
      end
    end
  end

  describe "Show" do

    let(:post) { FactoryGirl.create(:post) }

    describe 'given a valid Token' do

      before do
        token.generate_key!
        token.save
        header 'Authorization', "Bearer #{token.key}"
      end

      describe "given a valid published post id" do
        let(:post) { FactoryGirl.create(:published_post) }

        it "returns the post with the given id" do
          get "admin/posts/#{post.id}"
          last_response.status.must_equal 200
          response = JSON.parse(last_response.body)['post']
          assert_equal post.id, response['id']
          assert_equal post.title, response['title']
          assert_equal post.content, response['content']
        end
      end

      describe "given an unpublished post id" do
        let(:post) { FactoryGirl.create(:post) }

        it "returns the post with the given id" do
          get "admin/posts/#{post.id}"
          last_response.status.must_equal 200
          response = JSON.parse(last_response.body)['post']
          assert_equal post.id, response['id']
          assert_equal post.title, response['title']
          assert_equal post.content, response['content']
        end
      end

      describe "given an invalid post id" do

        it "returns 404 Not Found" do
          get "admin/posts/12345"
          last_response.status.must_equal 404
          last_response.body.must_equal ""
        end
      end
    end

    describe 'given no Token' do

      describe "given a valid published post id" do
        let(:post) { FactoryGirl.create(:published_post) }

        it "returns the post with the given id" do
          get "admin/posts/#{post.id}"
          last_response.status.must_equal 200
          response = JSON.parse(last_response.body)['post']
          assert_equal post.id, response['id']
          assert_equal post.title, response['title']
          assert_equal post.content, response['content']
        end
      end

      describe "given an unpublished post id" do
        let(:post) { FactoryGirl.create(:post) }

        it "returns 404 Not Found" do
          get "admin/posts/#{post.id}"
          last_response.status.must_equal 404
          last_response.body.must_equal ""
        end
      end
    end
  end

  describe "Update" do

    let(:post) { FactoryGirl.create(:post) }
    let(:attrs) {{ content: 'The new content' }}

    describe 'given a valid Token' do

      before do
        token.generate_key!
        token.save
        header 'Authorization', "Bearer #{token.key}"
      end

      describe "given a valid post id and valid attributes" do

        it "updates the post" do
          put "admin/posts/#{post.id}", post: attrs
          last_response.status.must_equal 200
          response = JSON.parse(last_response.body)['post']
          assert_equal post.id, response['id']
          assert_equal 'The new content', response['content']
        end
      end

      describe "given an invalid post id" do

        it "returns 404 Not Found" do
          put "admin/posts/12345", post: attrs
          last_response.status.must_equal 404
          last_response.body.must_equal ""
        end
      end

      describe "given invalid attributes" do
        let(:attrs) {{ title: '' }}

        it "returns 400 Bad Request with a hash of errors" do
          put "admin/posts/#{post.id}", post: attrs
          last_response.status.must_equal 400
          response = JSON.parse(last_response.body)['errors']
          assert_equal ["can't be blank"], response['title']
        end
      end
    end

    describe 'given an invalid Token' do
      before do
        header 'Authorization', "Bearer wrong"
      end

      it 'returns 401 Unauthorized' do
        put "admin/posts/#{post.id}", post: attrs
        last_response.status.must_equal 401
      end
    end
  end

  describe "Delete" do

    let(:post) { FactoryGirl.create(:post) }

    describe 'given a valid Token' do

      before do
        token.generate_key!
        token.save
        header 'Authorization', "Bearer #{token.key}"
      end

      describe "given a valid post id" do

        it "deletes the post and returns 204 No Content" do
          delete "admin/posts/#{post.id}"
          last_response.status.must_equal 204
          last_response.body.must_equal ""
          Post.exists?(post.id).must_equal false
        end
      end

      describe "given an invalid post id" do

        it "returns 404 Not Found" do
          delete "admin/posts/12345"
          last_response.status.must_equal 404
          last_response.body.must_equal ""
        end
      end
    end

    describe 'given an invalid Token' do
      before do
        header 'Authorization', "Bearer wrong"
      end

      it 'returns 401 Unauthorized' do
        delete "admin/posts/#{post.id}"
        last_response.status.must_equal 401
      end
    end
  end
end
