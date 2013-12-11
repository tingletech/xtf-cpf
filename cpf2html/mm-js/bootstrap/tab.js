/* ========================================================================
 * Bootstrap: tab.js v3.0.0
 * http://twbs.github.com/bootstrap/javascript.html#tabs
 * ========================================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ======================================================================== */
+function(e){"use strict";var t=function(t){this.element=e(t)};t.prototype.show=function(){var t=this.element,n=t.closest("ul:not(.dropdown-menu)"),o=t.attr("data-target");if(o||(o=t.attr("href"),o=o&&o.replace(/.*(?=#[^\s]*$)/,"")),!t.parent("li").hasClass("active")){var i=n.find(".active:last a")[0],r=e.Event("show.bs.tab",{relatedTarget:i});if(t.trigger(r),!r.isDefaultPrevented()){var s=e(o);this.activate(t.parent("li"),n),this.activate(s,s.parent(),function(){t.trigger({type:"shown.bs.tab",relatedTarget:i})})}}},t.prototype.activate=function(t,n,o){function i(){r.removeClass("active").find("> .dropdown-menu > .active").removeClass("active"),t.addClass("active"),s?(t[0].offsetWidth,t.addClass("in")):t.removeClass("fade"),t.parent(".dropdown-menu")&&t.closest("li.dropdown").addClass("active"),o&&o()}var r=n.find("> .active"),s=o&&e.support.transition&&r.hasClass("fade");s?r.one(e.support.transition.end,i).emulateTransitionEnd(150):i(),r.removeClass("in")};var n=e.fn.tab;e.fn.tab=function(n){return this.each(function(){var o=e(this),i=o.data("bs.tab");i||o.data("bs.tab",i=new t(this)),"string"==typeof n&&i[n]()})},e.fn.tab.Constructor=t,e.fn.tab.noConflict=function(){return e.fn.tab=n,this},e(document).on("click.bs.tab.data-api",'[data-toggle="tab"], [data-toggle="pill"]',function(t){t.preventDefault(),e(this).tab("show")})}(window.jQuery);