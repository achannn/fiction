require "test_helper"
require "minitest/autorun"

class ChatResponderTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    ChatResponder.class_eval do
      # we're testing the private get_response method directly
      # because the public call method is stubbed globally
      public :get_response
    end
  end

  test "it builds messages using chat history and the 3 most relevant chapters and blobs and then calls OpenAI chat api" do
    story = users(:one).stories.create(title: "story title", summary: "story summary")
    chapter1 = story.chapters.create(title: "chapter one", body: "chapter one body", embedding: embedding_with(0.00005))
    chapter2 = story.chapters.create(title: "chapter two", body: "chapter two body", embedding: embedding_with(0.00004))
    chapter3 = story.chapters.create(title: "chapter three", body: "chapter three body", embedding: embedding_with(0.00003))
    chapter4 = story.chapters.create(title: "chapter four", body: "chapter four body", embedding: embedding_with(0.00002))
    chapter5 = story.chapters.create(title: "chapter five", body: "chapter five body", embedding: embedding_with(0.00001))
    blob1 = story.blobs.create(title: "blob one", body: "blob one body", embedding: embedding_with(0.00005))
    blob2 = story.blobs.create(title: "blob two", body: "blob two body", embedding: embedding_with(0.00004))
    blob3 = story.blobs.create(title: "blob three", body: "blob three body", embedding: embedding_with(0.00003))
    blob4 = story.blobs.create(title: "blob four", body: "blob four body", embedding: embedding_with(0.00002))
    blob5 = story.blobs.create(title: "blob five", body: "blob five body", embedding: embedding_with(0.00001))

    chat = chapter4.chats.create(user: users(:one))
    chat_message1 = chat.chat_messages.create(user: users(:one), message: "hello bot")
    chat_message2 = chat.chat_messages.create(user: users(:system), message: "hello human")
    chat_message3 = chat.chat_messages.create(user: users(:one), message: "how are you?")

    # question_embedding is [0.00001, 0.00001, ...] (set in global stub for EmbeddingCreator)

    # Looking for most relevant chapters from 1-4
    # expected ordered relevant chapters is 4->3->2

    # Looking for most relevant blobs
    # expected ordered relevant blobs is 5->4->3

    api_mock = Minitest::Mock.new
    api_mock.expect(:chat, {"choices"=>[{"message"=>{"content"=>"reply"}}]}, parameters: {
      model: "gpt-3.5-turbo",
        messages: [
        {role: "system", content: "Answer the questions based on the story below, if the question can't be answered, say 'I dont know'.\n\n========================================================\n\nHere is the story:\n\nchapter four body chapter three body chapter two body\n\n========================================================\n\nHere is extra information about the story:\n\nblob five body blob four body blob three body"},
        {role: "user", content: "hello bot"},
        {role: "assistant", content: "hello human"},
        {role: "user", content: "how are you?"},
      ],
        max_tokens: 189
    })

    perform_enqueued_jobs do
      OpenAI::Client.stub :new, api_mock do
        ret = ChatResponder.new(chat_message3).get_response
        assert_equal "reply", ret
      end
    end
  end

  def embedding_with(replace_with)
    ret = embedding_creator_ret
    ret[0] = replace_with
    ret
  end
end
