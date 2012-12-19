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



class FiveC3
    constructor: () ->
        @events = []
        @typeaheadStrings
        @lastFullScreenItem
        @player
        @templates = {}
        
        @isotopeContainer = $('#eventItems')
        @isotopeContainer.isotope({
          itemSelector : '.item',
          layoutMode : 'masonry',
          animationMode: 'css'
        })

        $(window).resize( () ->
            console.log('resized')
        )

        templateFiles = ['item'] # Provide a list of files to fetch. Leave .html away
        @getTemplates(templateFiles)

        @refreshEventData()

        typeaheadOptions = {
          minLenght: 2
          source: @typeaheadStrings
        }
        $('.typeahead').typeahead(typeaheadOptions)

    getTemplates: (templateFiles) =>

        for templateFileName in templateFiles
            $.ajax(
                url: '/tpl/' + templateFileName + '.html'
                success: (dataFromServer) => @templates[templateFileName] = doT.template(dataFromServer)
                async: false
            )    

    writeEvents: () =>
        console.log($('#eventItems'))
        for evnt in @events
            item = $(@templates.item(evnt))
            @isotopeContainer.isotope('insert',item, @itemAdded)

    onItemClick: (e) =>
        if @lastFullScreenItem
            @lastFullScreenItem.css('width', '')
            @lastFullScreenItem.css('height', '')
        item = $(e.target)
        if ! item.hasClass('item')
            item = item.parents('.item')
        item.width(640)
        item.height(360)
        @isotopeContainer.isotope('reLayout')
        @lastFullScreenItem = $(item)

    onItemMouseMove: (e) =>
        # 

            # ...
    itemAdded: (addedItem) =>
        addedItem.click(@onItemClick)
        addedItem.mousemove(@onItemMouseMove)
                

    refreshEventData: () ->
        $.ajax( 
            url:'events'
            datatype: 'json'
            success: (dataFromServer) =>
                @events = dataFromServer
                @writeEvents()
            async: true
        )
    

$(document).ready( ->
    top.fiveC3 = new FiveC3()
)


