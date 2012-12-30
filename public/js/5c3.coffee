#
# 5c3.coffee
# Copyright (c) 2012 Thorsten Philipp <kyrios@kyri0s.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in the 
# Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the
# following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

top = this
top.replaceHtml = (el, html) ->
    if typeof(el) == 'string'
        oldEl = document.getElementById(el)
    else
        oldEl = el
    newEl = oldEl.cloneNode(false)
    newEl.innerHTML = html
    oldEl.parentNode.replaceChild(newEl, oldEl)
    return newEl

class FiveC3
    constructor: () ->
        @events = []
        @typeaheadStrings
        if screen.width < 767
            @columns = 1
        # else if screen.width < 1025
        #     @columns = 4
        else
            @columns = 5
        @lastactiveitem = {}
        @displayData = {} # Filtered and display ready data
        $('.btn-navbar').bind('touchstart',
            (e) ->
                console.log(e)
        )

        $('.conferenceFilter').click(@onConferenceFilterClick)

        @templates = {} # Contains the template functions
        templateFiles = ['item', 'items','popunder','typeahead'] # Provide a list of files to fetch. Leave .html away
        @getTemplates(templateFiles)
        @refreshEventData( =>
            @initBbq()
        )

    initBbq: () =>

        # // Override the default behavior of all `a` elements so that, when
        # // clicked, their `href` value is pushed onto the history hash
        # // instead of being navigated to directly.
         
        # // Bind a callback that executes when document.location.hash changes.
        $(window).bind( "hashchange", (e) =>
            # // In jQuery 1.4, use e.getState( "url" );
            url = $.bbq.getState();
            query = $.deparam.querystring( window.location.search );

            console.log(url.conference)
            if url.searchquery
                console.log('Searching for ' + url.searchquery)
                @filterEvents({title:url.searchquery,person:url.searchquery})
                return


            if !url.conference
                jQuery.bbq.pushState({conference:'29th Chaos Communication Congress'})
                return

            if @lastconference != url.conference
                if url.conference == 'Alle'
                    $('.conferenceFilter').removeClass('active')
                    $('[data-conference-title=Alle]').addClass('active') 
                    @filterEvents()
                else
                    @filterEvents({conference:url.conference})
                @lastconference = url.conference

            
            if url.event
                @showItem(url.event)
            


            # // You probably want to actually do something useful here..
        ) 
        # // Since the event is only triggered when the hash changes, we need
        # // to trigger the event now, to handle the hash the page may have
        # // loaded with.
        $(window).trigger( "hashchange" )

    onConferenceFilterClick: (e) =>
        e.preventDefault()
        e.stopPropagation()
        $('.conferenceFilter').removeClass('active')
        $(e.currentTarget).addClass('active')
        selectedConferenceTitle = $(e.currentTarget).attr('data-conference-title')
        if selectedConferenceTitle
            jQuery.bbq.pushState({conference:selectedConferenceTitle})
        else
            @filterEvents()

    onItemClick: (e) =>
        console.log('Click')
        state = jQuery.bbq.getState()
        jQuery.bbq.pushState({event:$(e.currentTarget).attr('data-event-id'),conference:state.conference},2)



    typeaheadSource: (query, callback) =>
        typeaheadSources = []
        for evnt in @events
            evnt.datatype = 'event'
            if evnt.title == 'Deutschlandfunk @ 29C3'
                continue
            typeaheadSources.push(evnt)
        for speaker in @speakers
            speaker.datatype = 'speaker'
            typeaheadSources.push(speaker)

        return typeaheadSources

    typeaheadMatcher: (item) ->
        re = new RegExp(this.query,'i')
        if item.datatype == 'event'
            if item.title.match(re)
                return true
            if typeof(item.subtitle) == 'string' and item.subtitle.match(re)
                return true
        if item.datatype == 'speaker'
            if item.name.match(re)
                return true

    typeaheadSorter: (items) ->

        newItems = []

        items.sort( (a,b) -> 
            if(a.datatype == 'event' and b.datatype == 'speaker')
                return -1
            if(a.datatype == 'speaker' and b.datatype == 'event')
                return 1
            if(a.datatype == b.datatype and a.datatype == 'event')
                if a.title.toLowerCase() > b.title.toLowerCase()
                    return 1
                if a.title.toLowerCase() < b.title.toLowerCase()
                    return -1
            if(a.datatype == b.datatype and a.datatype == 'speaker')
                if a.name.toLowerCase() > b.name.toLowerCase()
                    return 1
                if a.name.toLowerCase() < b.name.toLowerCase()
                    return -1
            return 0
        )
        lasttype = 'first'
        for item in items
            if lasttype == 'first'
                console.log('first')
                item.extraclass = 'firstevent'
            else
                item.extraclass = ''
            if item.datatype == 'speaker'
                if lasttype == 'event'
                    # Mark first event for css
                    item.extraclass = 'firstspeaker'
                else
                    item.extraclass = ''
                item.selectedValue = item.name
                # console.log(item.name)
            else
                item.selectedValue = item.title
            newItems.push(item)

            lasttype = item.datatype

        return newItems



    typeaheadUpdater: (item) ->
        jQuery.bbq.pushState({searchquery: item, conference: 'Alle'},2)
        # top.fiveC3.filterEvents()
        return(item)
        

    typeaheadHighlighter: (item) ->
      #   var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
      #     return item.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
      #   return '<strong>' + match + '</strong>'
      # })
        if typeof(item.title) == 'string'
            return(top.fiveC3.templates.typeahead(item))
        if typeof(item.name) == 'string'
            return(top.fiveC3.templates.typeahead(item))
        return(item.value)
        # if typeof(item.title) == 'string'
        #     return item.title
        # if typeof(item.name) == 'string'
        #     return item.name

    filterEvents: (filterattributes) =>
        @filterattributes = filterattributes
        console.log('Filter Attributes:')
        console.log(filterattributes)
        filteredData = @events.slice(0)
        if @filterattributes
            filteredData = filteredData.filter( (item) =>
                if item.title == 'Deutschlandfunk @ 29C3'
                    return false
                for k, v of @filterattributes
                    if k == 'person'
                        try 
                            for speaker in item.persons
                                if speaker == v
                                    return true
                        catch e
                            continue
                        
                    if item[k] == v
                        return true
                return false
            )

        # Sort the data by timestamp (ASCENDING)
        filteredData.sort( (a,b) -> 
            if(a.timestamp < b.timestamp)
                return -1
            if(a.timestamp > b.timestamp)
                return 1
            return 0
        )

        # Prepare the datastructure for display
        i = 0 # Item Number
        j = 0 # Row Number
        @displayData.rows = []
        @displayData.rows[0] = []
        @displayData.rows[0].rownumber = 0
        for item in filteredData
            item.number = i
            item.row = j
            @displayData.rows[j].push(item)
            i = i + 1
            if item.number % @columns == @columns - 1 # New Row
                j = j + 1
                @displayData.rows[j] = []
                @displayData.rows[j].rownumber = j

        @writeEvents()


    getTemplates: (templateFiles) =>
        for templateFileName in templateFiles
            $.ajax(
                url: '/tpl/' + templateFileName + '.html'
                success: (dataFromServer) => @templates[templateFileName] = doT.template(dataFromServer)
                async: false
            )

    writeEvents: (cb) =>
        items = @templates.items(@displayData)
        top.replaceHtml("content",items)
        @writtenEvents()
        

    writtenEvents: (items) =>
        $('.item').each( ->
            item = $(this)
            # item.tappable({
            #     callback: top.fiveC3.onItemClick
            #     cancelOnMove: true
            #     touchDelay: 500
            # })
            item.bind("click",top.fiveC3.onItemClick)

        )
        typeaheadOptions = {
            source: @typeaheadSource
            matcher: @typeaheadMatcher
            sorter: @typeaheadSorter
            updater: @typeaheadUpdater
            highlighter: @typeaheadHighlighter
        }
        @typeahead = $('.search-query').typeahead(typeaheadOptions)
     

    refreshEventData: (callback) ->
        $.ajax( 
            url:'/events'
            datatype: 'json'
            success: (dataFromServer) =>
                @events = dataFromServer
                for event in @events
                    if event.conference == '29th Chaos Communication Congress'
                        event.conferenceShort = '29c3'
                    if event.conference == '28th Chaos Communication Congress'
                        event.conferenceShort = '28c3'
                    if event.conference == '27th Chaos Communication Congress'
                        event.conferenceShort = '27c3'
                callback()
            async: true
        )
        $.ajax( 
            url:'/speakers'
            datatype: 'json'
            success: (dataFromServer) =>
                @speakers = dataFromServer
            async: true
        )

    getEventById: (id) =>
        for evnt in @events
            if evnt._id == id
                $.ajax(
                    url: '/events/' + evnt._id
                    datatype: 'json'
                    success: (dataFromServer) => 
                        jQuery.extend(evnt,dataFromServer)
                    async: false
                )
                return evnt
        

    showItem: (eventid) =>
        console.log('Showing: ' + eventid)
        if eventid
            item = $('[data-event-id=' + eventid + ']')
            item.id = item.attr('id')
            item.row = item.attr('data-row')
            $('.popundercontent').html('')
            eventObject = @getEventById(eventid)
            if item.row != @lastactiveitem.row
                row = $('#row' + item.row)
                lastRow = $('#row' + @lastactiveitem.row)
                lastRow.css('max-height','0px')
                row.css('max-height','500px')
                row.css('margin-bottom','20px')
                $(window).scrollTop(row.position().top - 80)

            top.replaceHtml('rowcontent_'+ item.row,@templates.popunder(eventObject))
            @initPlayer(eventObject) 
            @lastactiveitem = item
        else
            @lastactiveitem = {}
            $('.popunder').css('max-height','0px')
        
        
    initPlayer: (evnt) =>
        
        @player = new MediaElementPlayer( 
            $('video'), 
            success: (mediaElement, domObject) ->
                top.fiveC3.player = evnt._id
        
                mediaElement.addEventListener "play", ((e) ->
                    top.fiveC3.player.timer = setInterval("fiveC3.playcount()", 20000)
                ), false
                mediaElement.addEventListener "pause", ((e) ->
                    clearInterval(top.fiveC3.player.timer)
                ), false
            ,
            error: (error) ->
                console.log(error)
        )
        # console.log($('.mejs-overlay-button'))
        
    
    playcount: =>
        $.post "/viewcount/" + @activeEvent, (data) ->



    

$(document).ready( ->
    top.fiveC3 = new FiveC3()
)


