class SummernoteCleaner
  BLOCK_TAGS = 'h1, h2, h3, h4, h5, h6, p, ul, ol, dl'

  def self.clean(code)
    return code
    clean_code = code
    unless clean_code.start_with? '<p>'
      chunks = clean_code.split '<p>'
      chunks[0] = "<p>#{chunks[0]}</p>"
      clean_code = chunks.join '<p>'
    end
    clean_code
  end
end
