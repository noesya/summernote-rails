require 'test/unit'
require 'summernote-rails/cleaner'

class TestSummernoteCleaner < Test::Unit::TestCase

  def test_add_missing_p_around_text
    text = 'Text<br><a href="#">link</a>'
    assert_equal '<p>Text<br><a href="#">link</a></p>', SummernoteCleaner.clean(text)
  end

  def test_do_nothing_if_p_is_there
    text = '<p>Text</p>'
    assert_equal '<p>Text</p>', SummernoteCleaner.clean(text)
  end

  def test_add_p_before_an_existing_p
    text = 'Text<p>Second text</p>'
    assert_equal '<p>Text</p><p>Second text</p>', SummernoteCleaner.clean(text)
  end

end
