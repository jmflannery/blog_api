require 'test_helper'

class PostTest < ActiveSupport::TestCase

  let(:subject) { Post.new }

  describe '#publish' do

    it 'sets the published_at time' do
      published_at = Time.now
      subject.publish(published_at)
      subject.published_at.must_equal published_at
    end
  end
end
