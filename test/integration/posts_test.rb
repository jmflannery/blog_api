require 'test_helper'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class PostsTest < ActiveSupport::TestCase

  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  describe "Create" do

    describe "given valid parameters" do

      let(:attrs) {{ post: { title: 'My Post', content: 'This post rocks!' }}}

      it "creates a post" do
        now = Time.now
        post 'posts', attrs
        last_response.status.must_equal 201
        response = JSON.parse(last_response.body)['post']
        assert_match /\d+/, response['id'].to_s
        assert_equal 'My Post', response['title']
        assert_equal 'This post rocks!', response['content']
        created_at = Time.parse(response['created_at'])
        assert_equal now.year, created_at.year
        assert_equal now.min, created_at.min
        assert_equal now.sec, created_at.sec
      end
    end

    describe "given invalid parameters" do

      let(:attrs) {{ post: { title: '', content: 'This post rocks!' }}}

      it "returns 400 Bad Request with a hash of errors" do
        post 'posts', attrs
        last_response.status.must_equal 400
        response = JSON.parse(last_response.body)['errors']
        assert_equal ["can't be blank"], response['title']
      end
    end
  end

  describe "Index" do

    let(:post1) { posts(:post1) }
    let(:post2) { posts(:post2) }

    it "returns all posts" do
      now = Time.now
      get 'posts'
      last_response.status.must_equal 200
      response = JSON.parse(last_response.body)['posts']
      assert_equal 2, response.size
      assert_equal post1.id, response[0]['id']
      assert_equal post1.title, response[0]['title']
      assert_equal post2.content, response[1]['content']
      created_at = Time.parse(response[1]['created_at'])
      assert_equal now.min, created_at.min
      assert_equal now.sec, created_at.sec
    end
  end

  describe "Show" do

    let(:post) { posts(:post1) }

    describe "given a valid post id" do

      it "returns the post with the given id" do
        now = Time.now
        get "posts/#{post.id}"
        last_response.status.must_equal 200
        response = JSON.parse(last_response.body)['post']
        assert_equal post.id, response['id']
        assert_equal post.title, response['title']
        assert_equal post.content, response['content']
        created_at = Time.parse(response['created_at'])
        assert_equal now.min, created_at.min
        assert_equal now.sec, created_at.sec
      end
    end

    describe "given an invalid post id" do

      it "returns 404 Not Found" do
        get "posts/12345"
        last_response.status.must_equal 404
        last_response.body.must_equal ""
      end
    end
  end

  describe "Update" do

    let(:post) { posts(:post1) }
    let(:attrs) {{ content: 'The new content' }}

    describe "given a valid post id and valid attributes" do

      it "updates the post" do
        now = Time.now
        put "posts/#{post.id}", post: attrs
        last_response.status.must_equal 200
        response = JSON.parse(last_response.body)['post']
        assert_equal post.id, response['id']
        assert_equal 'The new content', response['content']
        updated_at = Time.parse(response['updated_at'])
        assert_equal now.min, updated_at.min
        assert_equal now.sec, updated_at.sec
      end
    end

    describe "given an invalid post id" do

      it "returns 404 Not Found" do
        put "posts/12345", post: attrs
        last_response.status.must_equal 404
        last_response.body.must_equal ""
      end
    end

    describe "given invalid attributes" do
      let(:attrs) {{ title: '' }}

      it "returns 400 Bad Request with a hash of errors" do
        put "posts/#{post.id}", post: attrs
        last_response.status.must_equal 400
        response = JSON.parse(last_response.body)['errors']
        assert_equal ["can't be blank"], response['title']
      end
    end
  end

  describe "Delete" do

    let(:post) { posts(:post1) }

    describe "given a valid post id" do

      it "deletes the post and returns 204 No Content" do
        delete "posts/#{post.id}"
        last_response.status.must_equal 204
        last_response.body.must_equal ""
        Post.exists?(post.id).must_equal false
      end
    end

    describe "given an invalid post id" do

      it "returns 404 Not Found" do
        delete "posts/12345"
        last_response.status.must_equal 404
        last_response.body.must_equal ""
      end
    end
  end
end
