require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class FileHelperTest < Test::Unit::TestCase
  include PeelMeAGrape::IsAttachment::FileHelper

  def test_random_filename
    mock_time_now = mock(:to_i => 1234, :usec => 567)
    Time.expects(:now).returns(mock_time_now)
    Process.expects(:pid).returns(89)
    assert_equal "1234.567.89", random_filename
  end

  def test_relative_path
    assert_equal "/file.jpg", relative_path("/some/dir/", "/some/dir/file.jpg")
    assert_equal "/file.jpg", relative_path("/some/dir/", "/some/other/../dir/file.jpg")
  end

  def test_sanitize_filename
    assert_equal "file_with_spaces.jpg", sanitize_filename("file with spaces.jpg")
    assert_equal "s_Ani__t__iz_ed_______.jpg", sanitize_filename("s@Ani%*t()iz\"ed<>()?! .jpg")
  end
end