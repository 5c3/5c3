// Generated by CoffeeScript 1.4.0
(function() {
  var FiveC3, top,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  top = this;

  top.replaceHtml = function(el, html) {
    var newEl, oldEl;
    if (typeof el === 'string') {
      oldEl = document.getElementById(el);
    } else {
      oldEl = el;
    }
    newEl = oldEl.cloneNode(false);
    newEl.innerHTML = html;
    oldEl.parentNode.replaceChild(newEl, oldEl);
    return newEl;
  };

  FiveC3 = (function() {

    function FiveC3() {
      this.playcount = __bind(this.playcount, this);

      this.initPlayer = __bind(this.initPlayer, this);

      this.itemAdded = __bind(this.itemAdded, this);

      this.onItemMouseMove = __bind(this.onItemMouseMove, this);

      this.onItemClick = __bind(this.onItemClick, this);

      this.getEventById = __bind(this.getEventById, this);

      this.writtenEvents = __bind(this.writtenEvents, this);

      this.writeEvents = __bind(this.writeEvents, this);

      this.getTemplates = __bind(this.getTemplates, this);

      this.resizeWindow = __bind(this.resizeWindow, this);

      this.updateItemWidth = __bind(this.updateItemWidth, this);

      this.moduleFilter = __bind(this.moduleFilter, this);

      this.filterEvents = __bind(this.filterEvents, this);

      var templateFiles;
      this.events = [];
      this.typeaheadStrings;
      this.lastFullScreenItem;
      this.player;
      this.activeEvent;
      this.templates = {};
      templateFiles = ['item', 'items', 'popunder'];
      this.getTemplates(templateFiles);
      this.minItemWidth = 310;
      this.itemHeight = 135;
      $(window).resize($.debounce(100, this.resizeWindow));
      this.updateItemWidth();
      this.refreshEventData();
    }

    FiveC3.prototype.filterEvents = function(filterattributes) {
      var i, item, _i, _len, _ref, _results,
        _this = this;
      console.log('Filtering');
      this.filterattributes = filterattributes;
      console.log(this.filterattributes);
      this.filteredEvents = this.events.slice(0);
      this.filteredEvents = this.filteredEvents.filter(function(event) {
        var k, v, _ref;
        _ref = _this.filterattributes;
        for (k in _ref) {
          v = _ref[k];
          if (event[k] === v) {
            return true;
          }
        }
        return false;
      });
      i = 1;
      _ref = this.filteredEvents;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.number = i;
        _results.push(i = i + 1);
      }
      return _results;
    };

    FiveC3.prototype.moduleFilter = function(object, index, array) {
      var filtervalue, _i, _len, _ref;
      _ref = this.filters.module.values;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filtervalue = _ref[_i];
        if (object[5].value === filtervalue) {
          return true;
        }
      }
      return false;
    };

    FiveC3.prototype.updateItemWidth = function() {
      var divWidth;
      divWidth = $("#isotopeContainer").width();
      this.columns = Math.floor(divWidth / this.minItemWidth);
      this.itemWidth = Math.floor(divWidth / this.columns);
      this.itemHeight = Math.floor(this.itemWidth * 135 / 240);
      console.log(this.itemHeight + 'px');
      return console.log('Columns:' + this.columns);
    };

    FiveC3.prototype.resizeWindow = function() {
      var timeDeltaResize, timeEndResize, timeResize;
      console.log('Resized');
      timeResize = new Date().getTime();
      this.updateItemWidth();
      $('.item').width(this.itemWidth).height(this.itemHeight);
      timeEndResize = new Date().getTime();
      timeDeltaResize = timeEndResize - timeResize;
      return console.log('Resize took ' + timeDeltaResize + ' ms');
    };

    FiveC3.prototype.getTemplates = function(templateFiles) {
      var templateFileName, _i, _len, _results,
        _this = this;
      _results = [];
      for (_i = 0, _len = templateFiles.length; _i < _len; _i++) {
        templateFileName = templateFiles[_i];
        _results.push($.ajax({
          url: '/tpl/' + templateFileName + '.html',
          success: function(dataFromServer) {
            return _this.templates[templateFileName] = doT.template(dataFromServer);
          },
          async: false
        }));
      }
      return _results;
    };

    FiveC3.prototype.writeEvents = function(cb) {
      var items;
      this.filteredEvents.itemWidth = this.itemWidth;
      this.filteredEvents.itemHeight = this.itemHeight;
      items = this.templates.items(this.filteredEvents);
      top.replaceHtml("isotopeContainer", items);
      return this.writtenEvents();
    };

    FiveC3.prototype.writtenEvents = function(items) {
      console.log('Written');
      return $('.item').each(function() {
        var item;
        item = $(this);
        return item.click(top.fiveC3.onItemClick);
      });
    };

    FiveC3.prototype.refreshEventData = function() {
      var _this = this;
      return $.ajax({
        url: '/events',
        datatype: 'json',
        success: function(dataFromServer) {
          _this.events = dataFromServer;
          _this.filterEvents({
            conference: '28th Chaos Communication Congress'
          });
          return _this.writeEvents();
        },
        async: true
      });
    };

    FiveC3.prototype.getEventById = function(id) {
      var evnt, _i, _len, _ref;
      _ref = this.events;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        evnt = _ref[_i];
        if (evnt._id === id) {
          return evnt;
        }
      }
    };

    FiveC3.prototype.onItemClick = function(e) {
      var currentEvent, item, itemNumber, lastItemInRow, nextIndex,
        _this = this;
      console.log('Click');
      item = $(e.currentTarget);
      item.id = item.attr('id');
      console.log(item.id);
      currentEvent = this.getEventById(item.attr('data-id'));
      if (this.lastActiveItemId !== item.id) {
        if (this.popunderContainer) {
          this.popunderContainer.animate({
            height: '0px'
          }, 400, function() {
            return $(this).remove();
          });
        }
        itemNumber = item.attr('data-number');
        nextIndex = (this.columns - itemNumber % this.columns) - 1;
        console.log(nextIndex);
        if (this.columns - 1 === nextIndex) {
          lastItemInRow = item;
        } else {
          lastItemInRow = item.nextAll(':eq(' + nextIndex + ')');
        }
        if (this.lastPopunder) {
          this.lastPopunder.animate({
            height: '0px'
          });
          setTimeout(2000, function() {
            return _this.lastPopunder.remove();
          });
        }
        this.popunderContainer = $(this.templates.popunder(currentEvent));
        this.popunderContainer.insertAfter(lastItemInRow);
        this.popunderContainer.animate({
          height: '500px'
        });
        this.initPlayer(currentEvent);
      }
      return this.lastActiveItemId = item.id;
    };

    FiveC3.prototype.onItemMouseMove = function(e) {};

    FiveC3.prototype.itemAdded = function(addedItem) {
      addedItem.click(this.onItemClick);
      return addedItem.mousemove(this.onItemMouseMove);
    };

    FiveC3.prototype.initPlayer = function(evnt) {
      var _this = this;
      return this.player = new MediaElementPlayer($('video'), {
        success: function(mediaElement, domObject) {
          _this.activeEvent = evnt._id;
          mediaElement.addEventListener("play", (function(e) {
            return _this.player.timer = setInterval("fiveC3.playcount()", 20000);
          }), false);
          return mediaElement.addEventListener("pause", (function(e) {
            return clearInterval(_this.player.timer);
          }), false);
        }
      });
    };

    FiveC3.prototype.playcount = function() {
      return $.post("/event/" + this.activeEvent, function(data) {});
    };

    return FiveC3;

  })();

  $(document).ready(function() {
    return top.fiveC3 = new FiveC3();
  });

}).call(this);
