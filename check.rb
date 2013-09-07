# Author: David Winiecki
# Project started September 2013

# For more info about anemone see http://anemone.rubyforge.org/information-and-examples.html
require 'anemone'

Anemone.crawl("http://en.wikipedia.org/") do |anemone|
  anemone.on_every_page do |page|
      puts page.url
  end
  # Limit crawl to just a couple pages.
  anemone.focus_crawl { |page| page.links.slice(0..1) }
end
