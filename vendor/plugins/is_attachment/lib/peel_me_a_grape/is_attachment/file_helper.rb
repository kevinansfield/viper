# Helper methods for dealing with Files and Tempfiles.
module PeelMeAGrape::IsAttachment::FileHelper
  # yields a new empty Tempfile to a block and returns the resulting Tempfile
  def with_temp_file(&block)
    returning Tempfile.new(random_filename, PeelMeAGrape::IsAttachment.tempfile_path) do |tmp|
      tmp = block.call(tmp)
    end
  end

  # creates and returns an empty Tempfile
  def create_empty_temp_file
    with_temp_file do |tmp|
      tmp.close
    end
  end

  # writes data to a new Tempfile and returns it.
  def write_to_temp_file(data)
    with_temp_file do |tmp|
      tmp.write data
      tmp.close
    end
  end

  # generates a kinda random name for our tempfile
  def random_filename
    now = Time.now
    "#{now.to_i}.#{now.usec}.#{Process.pid}"
  end

  # Computes the relative path between <tt>from_base</tt> and <tt>to_file</tt>
  # eg.
  #   relative_path("/tmp/is_attachment/", "/tmp/is_attachment/tmp_dir/file.jpg" ) => '/tmp_dir/file.jpg'
  def relative_path(from_base,to_file)
    from_base_expanded = File.expand_path(from_base)
    to_file_expanded = File.expand_path(to_file)
    to_file_expanded.gsub %r(^#{Regexp.escape(from_base_expanded)}), ''
  end

  # sanitizes filenames - strips off extra path information and replaces non alphanumeric characters with underscores.
  # EOIN: removed downcase as it broke existing filenames...
  def sanitize_filename(filename)
    return nil if filename.nil?
    returning filename.strip do |name|
      name.gsub! /^.*(\\|\/)/, ''
      name.gsub! /[^\w\.\-]/, '_'
    end
  end
  
  # returns the file extension from #filename. eg. filename of "my_image.jpg" returns 'jpg'
  def filename_extension
    split = filename.split('.')
    split.size > 1 ? split.last : nil rescue nil
  end
end
