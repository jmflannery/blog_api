require 'test_helper'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

describe "Posts" do

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
end
