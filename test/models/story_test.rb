require "test_helper"

class StoryTest < ActiveSupport::TestCase
  test "last_chapter returns the last chapter" do
    chapter2 = Chapter.create(story: stories(:one), number: 2, title: '2', body: "two")
    assert_equal chapter2, stories(:one).last_chapter
  end

  test "last_chapter returns the last chapter even after chapters are created and deleted" do
    chapter2 = Chapter.create(story: stories(:one), number: 2, title: '2', body: "two")
    chapter3 = Chapter.create(story: stories(:one), number: 3, title: '3', body: "three")
    assert_equal chapter3, stories(:one).last_chapter
    chapter3.destroy
    assert_equal chapter2, stories(:one).last_chapter
    chapter3_2 = Chapter.create(story: stories(:one), number: 3, title: '3-2', body: "three-two")
    assert_equal chapter3_2, stories(:one).last_chapter
  end

  test "last_chapter returns nil if there are no chapters" do
    chapters(:one).destroy
    assert_nil stories(:one).last_chapter
  end

  test "new stories automatically get a code" do
    new_story = Story.create(author: users(:one), title:"1", summary:"one")
    assert_equal false, new_story.code.nil?
  end
end
