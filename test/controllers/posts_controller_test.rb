require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest

  describe '#index' do
    before do
      Post.create({
        title: 'How to Skin a Cat',
        slug: 'how-to-skin-a-cat',
        content: 'Step one: get the sheers',
        published_at: Time.now
      })
      Post.create({
        title: 'Economic Warning Lights',
        slug: 'econcomic-warning-lights',
        content: "We've got to stop this train before it crashes...",
        published_at: Time.now
      })
    end

    it 'responds with 200 OK' do
      get posts_url
      assert_response :success
    end

    describe "with no parameters" do
      it 'serializes with the PostSerializer' do
        get posts_url
        post = JSON.parse(response.body)['posts'][0]
        assert_equal %w[id title slug content published_at tags], post.keys
      end
    end

    describe "with type=list" do
      it 'serializes with the Posts::ListItemSerializer' do
        get posts_url, params: { type: 'list' }
        post = JSON.parse(response.body)['posts'][0]
        assert_equal %w[id title slug published_at], post.keys
      end
    end
  end
end
