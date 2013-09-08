/* Copyright 2012 Karl Swedberg
 * Copyright 2012 "Joe Coder", stackexchange.com
 * Copyright 2013 David Winiecki
 *
 * This file is part of the Crawl Spell Check script.
 * 
 * the Crawl Spell Check script is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * the Crawl Spell Check script is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with the Crawl Spell Check script.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * Dynamically load a JavaScript file with JavaScript 
 *
 * Copyright 2013 David Winiecki
 *
 * Adapted from jQuerify.js by Joe Coder on stackexchange.com.
 * sqa.stackexchange.com/questions/2921/webdriver-can-i-inject-a-jquery-script-for-a-page-that-isnt-using-jquery#answer-3453
 *
 * Adapted July 2012 by Joe Coder from the jQuerify bookmarklet by Karl Swedberg.
 */

(function(scriptUrl, callback) {
  var script = document.createElement('script');
  var head = document.getElementsByTagName('head')[0];
  var done = false;
  console.log('1');
  script.onload = script.onreadystatechange = (function() {
    console.log('3');
    if (!done && (!this.readyState || this.readyState == 'loaded' 
        || this.readyState == 'complete')) {
          done = true;
          script.onload = script.onreadystatechange = null;
          head.removeChild(script);
          callback();
        }
  });
  script.src = scriptUrl;
  head.appendChild(script);
  console.log('2');
})(arguments[0], arguments[arguments.length - 1]);
