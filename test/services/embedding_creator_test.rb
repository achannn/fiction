require "test_helper"
require "minitest/autorun"

class EmbeddingCreatorTest < ActiveSupport::TestCase
  setup do
    # we're testing the private get_embedding method directly
    # because the public call method is stubbed globally
    EmbeddingCreator.class_eval do
      public :get_embedding
    end
  end

  test "it calls the openai embedding api with the input" do
    api_mock = Minitest::Mock.new
    api_mock.expect(:embeddings, {"data"=>[{"embedding"=> [0.001, 0.002]}]}, parameters:{model: "text-embedding-ada-002", input: "test input"})

    OpenAI::Client.stub :new, api_mock do
      ret = EmbeddingCreator.new("test input").get_embedding
      assert_equal [0.001, 0.002], ret
    end
  end

  test "it caches the response from the embedding api" do
    test_input = "test_input"
    api_mock = Minitest::Mock.new
    api_mock.expect(:embeddings, {"data"=>[{"embedding"=> [0.001, 0.002]}]}, parameters:{model: "text-embedding-ada-002", input: test_input})
    key = Digest::MD5.hexdigest(test_input)

    # before calling EmbeddingCreator, nothing in cache
    assert_nil Rails.cache.read(key)

    # call EmbeddingCreator for the first time, should cache
    OpenAI::Client.stub :new, api_mock do
      EmbeddingCreator.new(test_input).get_embedding
    end
    assert_equal [0.001, 0.002], Rails.cache.read(key)


    # call EmbeddingCreator, should hit cache and not API
    Rails.cache.write(key, [0.003, 0.004])
    ret = EmbeddingCreator.new(test_input).get_embedding
    assert_equal [0.003, 0.004], ret
  end
end
