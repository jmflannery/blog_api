require 'test_helper'

class PostsTest < ActiveSupport::TestCase

  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru').first
  end

  describe "Index" do

    let(:published1) { FactoryGirl.create(:published_post) }
    let(:published2) { FactoryGirl.create(:published_post) }
    let(:unpublished) { FactoryGirl.create(:post) }
    setup { [published1, published2, unpublished] }

    it "returns only published posts" do
      get 'posts'
      last_response.status.must_equal 200
      response = JSON.parse(last_response.body)['posts']
      assert_equal 2, response.size
      ids = response.map { |p| p['id'] }
      assert_includes ids, published1.id
      assert_includes ids, published2.id
      refute_includes ids, unpublished.id
    end
  end

  describe "Show" do

    describe "given a valid published post id" do
      let(:post) { FactoryGirl.create(:published_post) }

      it "returns the post with the given id" do
        get "posts/#{post.id}"
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
        get "posts/#{post.id}"
        last_response.status.must_equal 404
        last_response.body.must_equal ""
      end
    end

    describe "given an invalid post id" do

      it "returns 404 Not Found" do
        get "posts/wrong"
        last_response.status.must_equal 404
        last_response.body.must_equal ""
      end
    end
  end
end
