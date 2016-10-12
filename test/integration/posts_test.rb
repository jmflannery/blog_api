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
        post 'posts', attrs
        post = Post.last
        last_response.status.must_equal 201
        last_response.body.must_equal %Q({"post":{"id":#{post.id},"title":"My Post","content":"This post rocks!"}})
      end
    end

    describe "given invalid parameters" do

      let(:attrs) {{ post: { title: '', content: 'This post rocks!' }}}

      it "returns 400 with an error message" do
        post 'posts', attrs
        last_response.status.must_equal 400
        last_response.body.must_equal %Q({"error":{"title":["can't be blank"]}})
      end
    end
  end

  describe "Index" do

    let(:post1) { posts(:post1) }
    let(:post2) { posts(:post2) }

    it "returns all posts" do
      get 'posts'
      last_response.status.must_equal 200
      last_response.body.must_equal %Q({"posts":[{"id":277846598,"title":"My first Post","content":"This is the content of my first post."},{"id":159828990,"title":"My last Post","content":"This is the content of my last post."}]})
    end
  end

  describe "Show" do

    let(:post) { posts(:post1) }

    describe "given a valid post id" do

      it "returns the post with the given id" do
        get "posts/#{post.id}"
        last_response.status.must_equal 200
        last_response.body.must_equal %Q({"post":{"id":277846598,"title":"My first Post","content":"This is the content of my first post."}})
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
end
