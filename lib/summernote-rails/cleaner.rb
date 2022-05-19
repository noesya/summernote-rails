class SummernoteCleaner
  def self.clean(code)
    clean_code = code
    unless clean_code.start_with? '<p>'
      chunks = clean_code.split '<p>'
      chunks[0] = "<p>#{chunks[0]}</p>"
      clean_code = chunks.join '<p>'
    end
    clean_code
  end
end
