Spell check crawl
=================

Setup
-----

    # Open Terminal.
    
    # If you want to use rvm for Ruby version management (recommended) install it.
    \curl -sSL https://get.rvm.io | bash -s stable
    
    # Clone this project.
    git clone ssh://git@github.com:Vinietskyzilla/spell-check-crawl.git
    
    # Change to the spell-check-crawl directory.
    cd spell-check-crawl
    
    # Install the bundler gem.
    gem install bundler
    
    # Install all the other gem dependencies. (Reads gem dependencies from Gemfile.lock.)
    bundle install


Usage
-----

Run the check.rb script with Ruby. Protocol defaults to http if not specified.

    ruby check.rb https://example.com


Script behavior, specs
----------------------

This spell checker ignores all punctuation, including hyphens, and treats hyphenated words as separate words.

This script does not check grammar, only spelling.

This script is designed only to check English. Extending it for other languages, even similar languages like French or German, would be a LOT of work. I know from experience. (However, Spanish might be easier for all I know.)

This script does not check case, as in uppercase or lowercase. 'aNd' is treated exactly the same as 'and' or 'And'.

If this script finds a word in one of the dictionary files, it is identified as correctly spelled. If a word is not found in any dictionary, the word is recorded as misspelled.


Dictionary files
----------------

check.rb relies on 3 dictionary files. The first two are from Ubuntu and Firefox and stored in the lib directory. Additional words that should be ignored can be added to the custom dictionary file.


Help
----

For help, email david dot winiecki at gmail dot com.
