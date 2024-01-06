require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "prev returns the previous chapter" do
    chapter2 = stories(:one).chapters.create(title: "2", body: "two")
    assert_equal chapters(:one), chapter2.prev
  end

  test "prev returns nil if it is the first chapter" do
    stories(:one).chapters.create(title: "2", body: "two")
    assert_nil chapters(:one).prev
  end

  test "next returns the next chapter" do
    chapter2 = stories(:one).chapters.create(title: "2", body: "two")
    assert_equal chapter2, chapters(:one).next
  end

  test "next returns nil if it the last chapter" do
    chapter2 = stories(:one).chapters.create(title: "2", body: "two")
    assert_nil chapter2.next
  end

  # chapter numbers

  test "chapter numbers are automatically created sequentially" do
    story = users(:one).stories.create(title: "title", summary: "summary")
    chapter1 = story.chapters.create(title: "1", body: "one")
    chapter2 = story.chapters.create(title: "2", body: "two")
    chapter3 = story.chapters.create(title: "3", body: "three")
    assert_equal 1, chapter1.number
    assert_equal 2, chapter2.number
    assert_equal 3, chapter3.number
  end

  test "chapter numbers stay sequential while deleting and creating chapters" do
    story = users(:one).stories.create(title: "title", summary: "summary")
    chapter1 = story.chapters.create(title: "1", body: "one")
    chapter2 = story.chapters.create(title: "2", body: "two")
    chapter3 = story.chapters.create(title: "3", body: "three")
    assert_equal 1, chapter1.number
    assert_equal 2, chapter2.number
    assert_equal 3, chapter3.number

    chapter3.destroy
    chapter3_2 = story.chapters.create(title: "3_2", body: "three_two")
    assert_equal 1, chapter1.number
    assert_equal 2, chapter2.number
    assert_equal 3, chapter3_2.number

    chapter3_2.destroy
    chapter2.destroy
    chapter1.destroy
    chapter1_2 = story.chapters.create(title: "1_2", body: "one_two")
    chapter2_2 = story.chapters.create(title: "2_2", body: "two_two")
    chapter3_3 = story.chapters.create(title: "3_3", body: "three_three")
    assert_equal 1, chapter1_2.number
    assert_equal 2, chapter2_2.number
    assert_equal 3, chapter3_3.number
  end

  test "only the last chapter can be destroyed" do
    story = users(:one).stories.create(title: "title", summary: "summary")
    chapter1 = story.chapters.create(title: "1", body: "one")
    chapter2 = story.chapters.create(title: "2", body: "two")

    assert_raises(InvalidDestroyCall) do
      chapter1.destroy
    end
    chapter2.destroy
    chapter1.destroy
  end

  # embedding

  test "embeddings are generated when a chapter is created" do
    perform_enqueued_jobs do
      chapter = stories(:one).chapters.create(title: "title", body: "body")
      assert_equal embedding_creator_ret, Chapter.find(chapter.id).embedding
    end
  end

  test "embeddings are generated when a chapter body is updated" do
    perform_enqueued_jobs do
      chapter = chapters(:one)
      chapter.title = "updated title"
      chapter.save
      assert_nil Chapter.find(chapter.id).embedding

      chapter.body = "updated body"
      chapter.save
      assert_equal embedding_creator_ret, Chapter.find(chapter.id).embedding
    end
  end
end
