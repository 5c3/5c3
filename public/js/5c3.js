// Generated by CoffeeScript 1.3.3
(function() {
  var FiveC3, top;

  top = this;

  FiveC3 = (function() {

    function FiveC3() {
      var typeaheadOptions;
      this.events = [];
      this.typeaheadStrings;
      this.lastFullScreenItem;
      this.player;
      this.isotopeContainer = $('#eventItems');
      this.isotopeContainer.isotope({
        itemSelector: '.item',
        layoutMode: 'masonry'
      });
      $(window).resize(function() {
        return console.log('resized');
      });
      this.refreshEventData();
      typeaheadOptions = {
        minLenght: 2,
        source: this.typeaheadStrings
      };
      $('.typeahead').typeahead(typeaheadOptions);
    }

    FiveC3.prototype.writeEvents = function() {
      var evnt, item, _i, _len, _ref, _results,
        _this = this;
      console.log($('#eventItems'));
      _ref = this.events;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        evnt = _ref[_i];
        item = $('<div class="item" id="evnt_' + evnt.id + '">\
                <img class="thumbnail" src="' + evnt.id + '/1.jpg" alt="" />\
                <img class="thumbnail" src="' + evnt.id + '/2.jpg" alt="" />\
                <img class="thumbnail" src="' + evnt.id + '/3.jpg" alt="" />\
                <img class="thumbnail" src="' + evnt.id + '/4.jpg" alt="" />\
                <img class="thumbnail" src="' + evnt.id + '/5.jpg" alt="" />\
                <video width="640" height="360" style="width: 100%; height: 100%;" controls="controls" preload="none">\
                    <source src="http://media.ccc.de/ftp/congress/2011/mp4-h264-HQ/28c3-4676-en-apple_vs_google_client_platforms_h264.mp4" type="video/mp4" />\
                    <track kind="subtitles" src="captions.en.srt" srclang="en" />\
                </video>  \
                <div class="info">\
                <h1>' + evnt.title + '</h1>\
                <h2>' + evnt.subtitle + '</h2></div>"\
                \
                </div>');
        item.click(function(e) {
          console.log(_this.lastFullScreenItem);
          if (_this.lastFullScreenItem) {
            _this.lastFullScreenItem.css('width', '');
            _this.lastFullScreenItem.css('height', '');
          }
          item = $(e.target);
          if (!item.hasClass('item')) {
            item = item.parents('.item');
          }
          console.log(item);
          item.width(640);
          item.height(360);
          _this.isotopeContainer.isotope('reLayout');
          return _this.lastFullScreenItem = $(item);
        });
        _results.push(this.isotopeContainer.isotope('insert', item));
      }
      return _results;
    };

    FiveC3.prototype.refreshEventData = function() {
      var _this = this;
      return $.ajax({
        url: 'testdata/schedule.en.xml',
        datatype: 'xml',
        success: function(dataFromServer) {
          _this.events = [];
          $('event', dataFromServer).each(function(index, eventDom) {
            var evnt;
            evnt = {};
            evnt.start = $('start', eventDom).text();
            evnt.id = $(eventDom).attr('id');
            evnt.duration = $('duration', eventDom).text();
            evnt.title = $('title', eventDom).text();
            evnt.subtitle = $('subtitle', eventDom).text();
            return _this.events.push(evnt);
          });
          return _this.writeEvents();
        },
        async: true
      });
    };

    return FiveC3;

  })();

  $(document).ready(function() {
    return top.fiveC3 = new FiveC3();
  });

}).call(this);
