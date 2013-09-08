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
 * Dynamically load jQuery with JavaScript
 *
 * By Joe Coder on stackexchange.com.
 * sqa.stackexchange.com/questions/2921/webdriver-can-i-inject-a-jquery-script-for-a-page-that-isnt-using-jquery#answer-3453
 *
 * Adapted July 2012 by Joe Coder from the jQuerify bookmarklet by Karl Swedberg.
 */

(function(jqueryUrl, callback) {
    if (typeof jqueryUrl != 'string') {
        jqueryUrl = 'https://ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js';
    }
    if (typeof jQuery == 'undefined') {
        var script = document.createElement('script');
        var head = document.getElementsByTagName('head')[0];
        var done = false;
        script.onload = script.onreadystatechange = (function() {
            if (!done && (!this.readyState || this.readyState == 'loaded' 
                    || this.readyState == 'complete')) {
                done = true;
                script.onload = script.onreadystatechange = null;
                head.removeChild(script);
                callback();
            }
        });
        script.src = jqueryUrl;
        head.appendChild(script);
    }
    else {
        callback();
    }
})(arguments[0], arguments[arguments.length - 1]);
