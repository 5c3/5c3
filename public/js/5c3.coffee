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
        @lastFullScreenItem
        @player
        @activeEvent
        @templates = {} # Contains the template functions
        templateFiles = ['item', 'items'] # Provide a list of files to fetch. Leave .html away
        @getTemplates(templateFiles)
        @minItemWidth = 310
        # 240 x 135
        @itemHeight = 135
        $(window).resize( $.debounce(100,@resizeWindow ))
        @updateItemWidth()
        @refreshEventData()

    filterEvents: (filterattributes) =>
        console.log('Filtering')
        @filterattributes = filterattributes
        console.log(@filterattributes)
        @filteredEvents = @events.slice(0)
        @filteredEvents = @filteredEvents.filter( (event) =>
            for k, v of @filterattributes
                if event[k] == v
                    return true
            return false
        )

    moduleFilter: (object,index,array) =>
        for filtervalue in @filters.module.values
            if(object[5].value == filtervalue)
                return true
        return false

    updateItemWidth:() =>
        divWidth = $("#isotopeContainer").width()
        columns = Math.floor(divWidth / (@minItemWidth))

        @itemWidth = Math.floor(divWidth / columns)
        @itemHeight = Math.floor(@itemWidth * 135 / 240)

        console.log(@itemHeight + 'px')
        console.log('Columns:' + columns)

    resizeWindow: () =>
        console.log('Resized')
        timeResize = new Date().getTime()

        @updateItemWidth()      
        @writeEvents()

        timeEndResize = new Date().getTime()
        timeDeltaResize = timeEndResize - timeResize
        console.log('Resize took ' + timeDeltaResize + ' ms')


    getTemplates: (templateFiles) =>

        for templateFileName in templateFiles
            $.ajax(
                url: '/tpl/' + templateFileName + '.html'
                success: (dataFromServer) => @templates[templateFileName] = doT.template(dataFromServer)
                async: false
            )

    writeEvents: (cb) =>
        @filteredEvents.itemWidth = @itemWidth
        @filteredEvents.itemHeight = @itemHeight
        items = @templates.items(@filteredEvents)
        top.replaceHtml("isotopeContainer",items) # Way faster
        @writtenEvents()
        

    writtenEvents: (items) =>
        console.log('Written')

        # for item in items
        #     $(item).click(@onItemClick)
        #     $(item).mousemove(@onItemMouseMove)             

    refreshEventData: () ->
        $.ajax( 
            url:'/events'
            datatype: 'json'
            success: (dataFromServer) =>
                @events = dataFromServer
                @filterEvents({conference:'28th Chaos Communication Congress'})
                @writeEvents()
            async: true
        )

    onItemClick: (e) =>
        if @lastFullScreenItem
            @lastFullScreenItem.css('width', '')
            @lastFullScreenItem.css('height', '')
        item = $(e.target)
        if ! item.hasClass('item')
            item = item.parents('.item')
        item.width(740)
        item.height(425)
        @lastFullScreenItem = $(item)

    onItemMouseMove: (e) =>
        # 

            # ...
    itemAdded: (addedItem) =>
        addedItem.click(@onItemClick)
        addedItem.mousemove(@onItemMouseMove)
        
        
    initPlayer: (evnt) =>
    
        $("#evnt_" + @activeEvent + " .player").html ""  if @activeEvent
        $("#evnt_" + evnt._id + " .player").append "<video src=\"#\"></video>"
    
        videoElement = $("#evnt_" + evnt._id + " video")
        videoElement.attr("src", evnt.video)
        videoElement.attr("type", "video/mp4")
        videoElement.width("100%")
        videoElement.height("100%")
        videoElement.attr("preload", "none")
        videoElement.attr("poster", "/thumbs/" + evnt._id + "/poster_640.jpg")
    
        @player = new MediaElementPlayer(videoElement, success: (mediaElement, domObject) =>
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


