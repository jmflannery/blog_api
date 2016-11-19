require 'test_helper'

class Admin::PostsTest < ActiveSupport::TestCase

  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  describe "Create" do

    describe "given valid parameters" do

      let(:attrs) {{ title: 'My Post', content: 'This post rocks!' }}

      it "creates a post" do
        post 'admin/posts', post: attrs
        last_response.status.must_equal 201
        response = JSON.parse(last_response.body)['post']
        assert_match /\d+/, response['id'].to_s
        assert_equal 'My Post', response['title']
        assert_equal 'This post rocks!', response['content']
      end
    end

    describe "given invalid parameters" do

      let(:attrs) {{ post: { title: '', content: 'This post rocks!' }}}

      it "returns 400 Bad Request with a hash of errors" do
        post 'admin/posts', attrs
        last_response.status.must_equal 400
        response = JSON.parse(last_response.body)['errors']
        assert_equal ["can't be blank"], response['title']
      end
    end
  end

  describe "Index" do

    let(:post1) { FactoryGirl.create(:post) }
    let(:post2) { FactoryGirl.create(:post) }
    setup { [post1, post2] }

    it "returns all posts" do
      get 'admin/posts'
      last_response.status.must_equal 200
      response = JSON.parse(last_response.body)['posts']
      assert_equal 2, response.size
      assert_equal post1.id, response[0]['id']
      assert_equal post1.title, response[0]['title']
      assert_equal post2.content, response[1]['content']
    end
  end

  describe "Show" do

    let(:post) { FactoryGirl.create(:post) }

    describe "given a valid post id" do

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

  describe "Update" do

    let(:post) { FactoryGirl.create(:post) }
    let(:attrs) {{ content: 'The new content' }}

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

  describe "Delete" do

    let(:post) { FactoryGirl.create(:post) }

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
end