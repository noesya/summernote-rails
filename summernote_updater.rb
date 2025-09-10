require 'json'
require 'net/http'
require 'open-uri'

class SummernoteUpdater
  attr_reader :tmp, :zip_file, :dist_directory

  FILES = [
    ['summernote-bs4.css', 'vendor/assets/stylesheets/summernote-bs4.css'],
    ['summernote-bs4.css.map', 'vendor/assets/stylesheets/summernote-bs4.css.map'],
    ['summernote-bs4.js', 'vendor/assets/javascripts/summernote/summernote-bs4.js'],
    ['summernote-bs4.js.map', 'vendor/assets/javascripts/summernote/summernote-bs4.js.map'],
    ['summernote-bs4.min.css', 'vendor/assets/stylesheets/summernote-bs4.min.css'],
    ['summernote-bs4.min.js', 'vendor/assets/javascripts/summernote/summernote-bs4.min.js'],

    ['summernote-bs5.css', 'vendor/assets/stylesheets/summernote-bs5.css'],
    ['summernote-bs5.css.map', 'vendor/assets/stylesheets/summernote-bs5.css.map'],
    ['summernote-bs5.js', 'vendor/assets/javascripts/summernote/summernote-bs5.js'],
    ['summernote-bs5.js.map', 'vendor/assets/javascripts/summernote/summernote-bs5.js.map'],
    ['summernote-bs5.min.css', 'vendor/assets/stylesheets/summernote-bs5.min.css'],
    ['summernote-bs5.min.js', 'vendor/assets/javascripts/summernote/summernote-bs5.min.js'],

    ['summernote-lite.css', 'vendor/assets/stylesheets/summernote-lite.css'],
    ['summernote-lite.css.map', 'vendor/assets/stylesheets/summernote-lite.css.map'],
    ['summernote-lite.js', 'vendor/assets/javascripts/summernote/summernote-lite.js'],
    ['summernote-lite.js.map', 'vendor/assets/javascripts/summernote/summernote-lite.js.map'],
    ['summernote-lite.min.css', 'vendor/assets/stylesheets/summernote-lite.min.css'],
    ['summernote-lite.min.js', 'vendor/assets/javascripts/summernote/summernote-lite.min.js'],

    ['summernote.css', 'vendor/assets/stylesheets/summernote.css'],
    ['summernote.css.map', 'vendor/assets/stylesheets/summernote.css.map'],
    ['summernote.js', 'vendor/assets/javascripts/summernote/summernote.js'],
    ['summernote.js.map', 'vendor/assets/javascripts/summernote/summernote.js.map'],
    ['summernote.min.css', 'vendor/assets/stylesheets/summernote.min.css'],
    ['summernote.min.js', 'vendor/assets/javascripts/summernote/summernote.min.js'],
  ]

  DIRECTORIES = [
    ['plugin', 'vendor/assets/javascripts/summernote/plugin'],
    ['lang', 'vendor/assets/javascripts/summernote/lang'],
    ['font', 'vendor/assets/fonts']
  ]

  CSS_FILES = [
    'vendor/assets/stylesheets/summernote.css',
    'vendor/assets/stylesheets/summernote.min.css',
    'vendor/assets/stylesheets/summernote-bs4.css',
    'vendor/assets/stylesheets/summernote-bs4.min.css',
    'vendor/assets/stylesheets/summernote-bs5.css',
    'vendor/assets/stylesheets/summernote-bs5.min.css',
    'vendor/assets/stylesheets/summernote-lite.css',
    'vendor/assets/stylesheets/summernote-lite.min.css'
  ]

  def initialize
    @tmp = 'tmp'
    @zip_file = 'tmp/summernote.zip'
    @dist_directory = 'tmp/dist'
    execute
  end

  protected

  def execute
    clean_tmp
    return unless download_release_file
    unzip
    build
    clean_assets
    copy_assets
    fix_fonts
    puts "[SummernoteUpdater] Version #{tag_name} updated"
    puts "[SummernoteUpdater] Please upgrade version in lib/summernote-rails/version.rb, test thoroughly, then release"
  end

  def clean_tmp
    puts '[SummernoteUpdater] Cleaning tmp directory'
    FileUtils.rm_rf(tmp)
    FileUtils.mkdir_p(tmp)
  end

  def download_release_file
    puts '[SummernoteUpdater] Downloading release Zip from Github'
    zip_url = "https://github.com/summernote/summernote/archive/refs/tags/#{tag_name}.zip"
    download = URI.open(zip_url)
    IO.copy_stream(
      URI.open(zip_url), 
      zip_file
    )
    unless File.exist?(zip_file)
      puts 'No zip to process. Exiting...'
      return false
    end
    true
  end

  def tag_name
    @tag_name ||= JSON.parse(
        Net::HTTP.get_response(
          URI.parse(
            'https://api.github.com/repos/summernote/summernote/releases/latest'
          )
        ).body
      )['tag_name']
  end

  def unzip
    puts '[SummernoteUpdater] Unzipping'
    `unzip -d #{dist_directory} #{zip_file}`
  end

  def clean_assets
    puts '[SummernoteUpdater] Cleaning old JS and CSS files'

    `rm -rf vendor/assets/stylesheets`
    `rm -rf vendor/assets/fonts`
    `rm -rf vendor/assets/javascripts/lang`
    `rm -rf vendor/assets/javascripts/plugin`

    FileUtils.mkdir_p('vendor/assets/stylesheets')
    FileUtils.mkdir_p('vendor/assets/fonts')
    FileUtils.mkdir_p('vendor/assets/javascripts/summernote/lang')
    FileUtils.mkdir_p('vendor/assets/javascripts/summernote/plugin')
  end

  def build
    puts "[SummernoteUpdater] Building #{base_path} (following logs come from yarn)"
    `cd #{base_path} && yarn install && yarn build`
  end

  def copy_assets
    puts '[SummernoteUpdater] Copying new JS and CSS files'
    FILES.each do |from, to|
      `cp #{dist_path}/#{from} #{to}`
    end
    DIRECTORIES.each do |from, to|
      `cp -R #{dist_path}/#{from}/* #{to}`
    end
  end

  def base_path
    @base_path ||= "tmp/dist/summernote-#{tag_name.gsub('v', '')}"
  end

  def dist_path
    @dist_path ||= "#{base_path}/dist"
  end

  def fix_fonts
    puts '[SummernoteUpdater] Fixing font URLs in CSS files'

    CSS_FILES.each do |css_path|
      css_file = File.read(css_path)
      css_file = css_file.gsub(/url\(("\.\/)?font\/(summernote.[a-z0-9#?]+)(")?\)/, 'url(asset-path("\2"))')
      File.open(css_path, "w") {|old_css_file| old_css_file.print css_file}
    end
  end


end