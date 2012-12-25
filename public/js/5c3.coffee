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
        @displayData = {} # Filtered and display ready data

        @templates = {} # Contains the template functions
        templateFiles = ['item', 'items','popunder'] # Provide a list of files to fetch. Leave .html away
        @getTemplates(templateFiles)

        @refreshEventData()

    filterEvents: (filterattributes) =>
        console.log('Filtering')
        @filterattributes = filterattributes
        console.log(@filterattributes)
        filteredData = @events.slice(0)
        filteredData = filteredData.filter( (event) =>
            for k, v of @filterattributes
                if event[k] == v
                    return true
            return false
        )

        # Prepare the datastructure for display
        i = 0 # Item Number
        j = 0 # Row Number
        @displayData.rows = []
        @displayData.rows[0] = []
        for item in filteredData
            item.number = i
            item.row = j
            @displayData.rows[j].push(item)
            i = i + 1
            if item.number % @columns == @columns - 1 # New Row
                j = j + 1
                @displayData.rows[j] = []

        console.log(@displayData)
            # ...
        

    # moduleFilter: (object,index,array) =>
    #     for filtervalue in @filters.module.values
    #         if(object[5].value == filtervalue)
    #             return true
    #     return false

    # updateItemWidth:() =>
    #     divWidth = $("#isotopeContainer").width()
    #     @columns = Math.floor(divWidth / (@minItemWidth))

    #     @itemWidth = Math.floor(divWidth / @columns)
    #     @itemHeight = Math.floor(@itemWidth * 135 / 240)

    #     console.log(@itemHeight + 'px')
    #     console.log('Columns:' + @columns)

    # resizeWindow: () =>
    #     console.log('Resized')
    #     timeResize = new Date().getTime()

    #     @updateItemWidth()
    #     $('.item').width(@itemWidth).height(@itemHeight)      
    #     # @writeEvents()

    #     timeEndResize = new Date().getTime()
    #     timeDeltaResize = timeEndResize - timeResize
    #     console.log('Resize took ' + timeDeltaResize + ' ms')


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
        # @writtenEvents()
        

    writtenEvents: (items) =>
        $('.item').each( ->
            item = $(this)
            # item.click(top.fiveC3.onItemClick)
        )
     

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

    # getEventById: (id) =>
    #     for evnt in @events
    #         if evnt._id == id
    #             return evnt
        

    # onItemClick: (e) =>
    #     item = $(e.currentTarget)
    #     item.id = item.attr('id')

    #     currentEvent = @getEventById(item.attr('data-id'))
    #     if @lastActiveItemId != item.id
    #         if @popunderContainer
    #             @popunderContainer.animate(
    #                 {height:'0px'},
    #                 400,
    #                 -> $(this).remove()
    #             )

    #         itemNumber = item.attr('data-number')
    #         nextIndex = (@columns - itemNumber % @columns) - 1
    #         console.log(nextIndex)
    #         if @columns - 1 == nextIndex
    #             lastItemInRow = item
    #         else
    #             lastItemInRow = item.nextAll(':eq(' + nextIndex + ')')
    #         if @lastPopunder
    #             @lastPopunder.animate({height:'0px'})
    #             setTimeout(2000, =>
    #                 @lastPopunder.remove())
            
    #         # Insert spacer after last div in this row
    #         @popunderContainer = $(@templates.popunder(currentEvent))
            
    #         @popunderContainer.insertAfter(lastItemInRow)
    #         @popunderContainer.animate({height:'380px'})
    #         @initPlayer(currentEvent)

    #     @lastActiveItemId = item.id
        

        
        

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


