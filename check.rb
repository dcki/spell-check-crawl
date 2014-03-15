# Copyright 2013 David Winiecki
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# The first version of this script was completed in September 2013.

# To do:
# Make it easier to add words to the custom dictionary.

# For more about anemone see http://anemone.rubyforge.org/information-and-examples.html
require 'anemone'
# For more about Selenium WebDriver, see http://docs.seleniumhq.org/docs/03_webdriver.jsp#introducing-the-selenium-webdriver-api-by-example
require 'selenium-webdriver'
require 'set'

def get_options
  # To do: get command line options here or input from stdin for website domain or page.
  @domain = "http://en.wikipedia.org/"

  # To do: make it possible to spell check a single page.
  # @page = 

  # To do: Make it possible to re-review only those pages that were found to have errors in a previous crawl, using a specified previous log file as input.
  # @input_log = 

  # To do: get style for highlighting <span> elements from command line if default style is not desirable.
  # The style information must use the syntax jQuery expects. This is different from CSS!!
  @span_js_style = 'border: "solid magenta 2px", backgroundColor: "yellow"'

  # To do:
  # If true, any word that is all caps should be skipped, never identified as an error.
  # @ignore_all_caps = true

  # Limit the crawl to just a few pages. Raise the number to crawl more pages. Set to nil to disable.
  @limit_crawl = 1
  # @limit_crawl = nil

  # To do: Make this an option:
  # Maximum number of pages this script will attempt to open with Selenium-WebDriver at one time.
  #@page_open_max = 50

  @load_jQuery_script_file = 'lib/jQuerify.js'
  @load_script_file = 'lib/load_js_file.js'
  @jQuery_file = 'lib/jquery-2.0.3.min.js'
  @highlight_file = 'lib/jquery.highlight.js'
end

def initialize_log
  # Determine log filename:
  # Check if log directory exists. If not, create it.
  # Check if other log files exist.
  # Append appropriate suffix to log file (e.g. '_004').
  # Return resulting filename.

  # Send all output to log file in addition to stdout:
end

def read_dictionaries
  @dict = Set.new

  linux_dict = File.read('lib/ubuntu_12_04_usr_share_dict_words_american_english').lines.to_a
  linux_dict.each do |line|
    line.strip!
    @dict << line
  end

  firefox_dict = File.read('lib/en-US-from-Firefox.dic').lines.to_a
  firefox_dict.each do |line|
    line.strip!
    @dict << line
  end

  custom_dict = File.read('custom_dictionary').lines.to_a
  custom_dict.each do |line|
    line.strip!
    @dict << line
  end
end

def misspelled?(word)
  return !(@dict.include? word.downcase)
end

# If page contains errors in innerHTML text, add page and error words to @errors.
def record_page_errors(page)
  @errors ||= { }

  # To do: make it an option to get the body text using this as an alternative:
  # This gets the body text using Selenium WebDriver and JavaScript.
  #@driver.get page.url
  #body_text = @driver.execute_script "return document.body.textContent;"

  # This gets the body text using Nokogiri.
  # Credit for the next couple lines goes to Levi and ema on stackoverflow:
  # stackoverflow.com/questions/2505104/html-to-plain-text-with-ruby#answer-2505173
  page.doc.css('script, link').each { |node| node.remove }
  body_text = page.doc.text.dup

  # Parse the large string of page text into individual word strings, removing all non-alpha characters.
  words = body_text.split(/[^a-zA-Z]/)

  # Remove trailing "'s" from each word.
  # Probably no longer necessary now that we throw away all non-alphas.
  words.each do |word|
    word.gsub!(/'s$/, '')
  end

  unique_words = Set.new words

  unique_words.each do |word|
    if misspelled? word then
      if @errors[page.url] then
        @errors[page.url] << word
      else
        @errors[page.url] = [word]
      end
    end
  end
end

# Returns true if errors were found on the page in the record_page_errors function.
def page_has_errors?(page)
  return @errors[page.url]
end

def load_jQuery
  # From user megaxelize on stackoverflow.com.
  # stackoverflow.com/questions/17753655/timeouterror-using-selenium-webdriver-in-ruby#answer-18002146
  @driver.manage.timeouts.implicit_wait = 20
  @driver.manage.timeouts.script_timeout = 20
  @driver.manage.timeouts.page_load = 20

  # Load jQuery
  @driver.execute_async_script(File.read(@load_jQuery_script_file), @jQuery_file)

  # Load jQuery highlighter plugin
  #@driver.execute_async_script(File.read(@load_script_file), @highlight_file)
  @driver.execute_script(File.read(@highlight_file))
end

def highlight_word(word)
  @hl_class = 'highlight_crawl_spell_check'
  @driver.execute_script "jQuery('body').highlight('#{word}', { className: '#{@hl_class}', wordsOnly: true, caseSensitive: true });"
  @driver.execute_script "jQuery(\".#{@hl_class}\").css({ #{@span_js_style} });"
end

def open_and_highlight(url)
  words = @errors[url]
  @driver.get url
  
  load_jQuery
  
  words.each { |word| highlight_word word }
end

def page_errors_string(url)
  "#{url}: #{@errors[url].join ', '}"
end

def crawl
  @errors = { }
  Anemone.crawl(@domain) do |anemone|
    anemone.on_every_page do |page|
      begin
        puts page.url
        record_page_errors page
        if page_has_errors? page then
          puts '|'
        else
          puts '-'
        end
      rescue => e
        puts 'BEGIN ERROR'
        begin
          puts "Error processing #{page.url}: #{e}"
          puts e.backtrace[0..2]
        rescue => e2
          puts "Error processing page: #{e}"
          puts e.backtrace[0..2]
          puts "(Page url not availabe due to further error: #{e2})"
        end
        puts 'END ERROR'
      end
    end
    # Limit crawl to just a couple pages.
    # DEBUG
    if @limit_crawl then
      anemone.focus_crawl { |page| page.links.slice(0..@limit_crawl) }
    end
  end
end

def review
  display_urls = []
  @errors.keys.each do |url|
    display_urls << url
  end

  quit = false

  until quit
    (0..display_urls.length-1).each do |i|
      puts "#{i} #{page_errors_string(display_urls[i])}\n\n"
    end
    puts "Type a number to review the errors on that page, or 'q' to quit."
    # To do: make it possible to open and highlight all pages at once.
    # puts "Type a number to review the errors on that page, 'a' to review all, or 'q' to quit."
    # To do: After reviewing from logs is implemented:
    # puts "Type a number to review the errors on that page, or 'q' to quit. (You can review these errors at a later time without re-crawling by...)"
    input = gets

    if /^q/ =~ input.downcase then
      quit = true
      break
      # To do: open all pages at once.
      # elsif /^a/ =~ input.downcase then
      #   puts "Are you sure? This will open ALL PAGES containing errors simeltaneously, in separate windows. (y/n)"
      #   if /^y/ =~ gets.downcase != nil then
      #     if display_urls.length <= @page_open_max then


      #     else
      #       puts "Number of pages to open, #{display_urls.length}, is greater than specified maximum, #{@page_open_max}. Override the @page_open_max variable to open this many pages."
      #     end
      #   else
      #     puts "Reviewing all aborted by user."
      #   end
    else
      i = input.to_i.abs
      if i < display_urls.length then
        url = display_urls[i]
        open_and_highlight url
      else
        puts "There is no listed page corresponding to that number."
      end
    end
  end
end

get_options
initialize_log
read_dictionaries
@driver = Selenium::WebDriver.for :firefox
crawl
review
begin
  @driver.quit
rescue Errno::ECONNREFUSED # If the browser window was already closed, ignore this error.
end
