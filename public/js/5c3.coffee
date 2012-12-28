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
        @columns = 5
        @lastactiveitem = {}
        @displayData = {} # Filtered and display ready data

        @templates = {} # Contains the template functions
        templateFiles = ['item', 'items','popunder','typeahead'] # Provide a list of files to fetch. Leave .html away
        @getTemplates(templateFiles)
        @refreshEventData()

    typeaheadSource: (query, callback) =>
        typeaheadSources = []
        for evnt in @events
            evnt.datatype = 'event'
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
        # newItems.push({datatype:'seperator', value: '<div class="typeahead_seperator">Events</div>'})
        for item in items
            if lasttype == 'first'
                console.log('first')
                item.extraclass = 'firstevent'
            if item.datatype == 'speaker'
                if lasttype == 'event'
                    # Mark first event for css
                    item.extraclass = 'firstspeaker'
                item.selectedValue = item.name
                # console.log(item.name)
            else
                item.selectedValue = item.title
                console.log(item.title)
            newItems.push(item)

            lasttype = item.datatype

        return newItems



    typeaheadUpdater: (item) ->
        top.fiveC3.filterEvents({title: item,person: item})
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
        filteredData = @events.slice(0)
        if @filterattributes
            filteredData = filteredData.filter( (item) =>
                for k, v of @filterattributes
                    if k == 'person'
                        for speaker in item.persons
                            if speaker == v
                                return true
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
            item.click(top.fiveC3.onItemClick)
        )
        typeaheadOptions = {
            source: @typeaheadSource
            matcher: @typeaheadMatcher
            sorter: @typeaheadSorter
            updater: @typeaheadUpdater
            highlighter: @typeaheadHighlighter
        }
        @typeahead = $('.search-query').typeahead(typeaheadOptions)
     

    refreshEventData: () ->
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
                @filterEvents()
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
                return evnt
        

    onItemClick: (e) =>
        console.log('click')
        item = $(e.currentTarget)
        item.id = item.attr('id')
        item.row = item.attr('data-row')
        item._id = item.attr('data-event-id')
        console.log(item.id)
        console.log(@lastactiveitem.id)
        if item.id != @lastactiveitem.id
            console.log('A item was clicked that"s not the previous one')
            eventObject = @getEventById(item._id)
            if item.row != @lastactiveitem.row
                row = $('#row' + item.row)
                lastRow = $('#row' + @lastactiveitem.row)
                lastRow.css('max-height','0px')
                row.css('max-height','300px')

            top.replaceHtml('rowcontent_'+ item.row,@templates.popunder(eventObject))
            @initPlayer(eventObject) 
            @lastactiveitem = item      

    onItemMouseMove: (e) =>
        # 

            # ...
    itemAdded: (addedItem) =>
        addedItem.click(@onItemClick)
        addedItem.mousemove(@onItemMouseMove)
        
        
    initPlayer: (evnt) =>
        
        @player = new MediaElementPlayer($('video'), success: (mediaElement, domObject) =>
            @activeEvent = evnt._id
    
            mediaElement.addEventListener "play", ((e) =>
                @player.timer = setInterval("fiveC3.playcount()", 20000)
            ), false
            mediaElement.addEventListener "pause", ((e) =>
                clearInterval(@player.timer)
            ), false
        )
    
    playcount: =>
        $.post "/event/" + @activeEvent, (data) ->

    

$(document).ready( ->
    top.fiveC3 = new FiveC3()
)


