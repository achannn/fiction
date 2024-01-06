require "test_helper"

class BlobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "embeddings are generated when a blob is created" do
    perform_enqueued_jobs do
      blob = stories(:one).blobs.create(title: "title", body: "body")
      assert_equal embedding_creator_ret, Blob.find(blob.id).embedding
    end
  end

  test "embeddings are generated when a blob body is updated" do
    perform_enqueued_jobs do
      blob = blobs(:one)
      blob.title = "updated title"
      blob.save
      assert_nil Blob.find(blob.id).embedding

      blob.body = "updated body"
      blob.save
      assert_equal embedding_creator_ret, Blob.find(blob.id).embedding
    end
  end
end
