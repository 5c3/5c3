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
		@typeaheadStrings = []

		@resizeSidebar()
		$(window).resize(@resizeSidebar)
		@refreshEventData()

		typeaheadOptions = {
			minLenght: 2
			source: @typeaheadStrings
		}
		$('.typeahead').typeahead(typeaheadOptions)
		

	refreshEventData: () ->
		$.ajax( 
            url:'testdata/schedule.en.xml'
            datatype: 'xml'
            success: (dataFromServer) => 
            	@events = []
            	$('event',dataFromServer).each (index, eventDom) =>
            		evnt = {}
            		evnt.start = $('start',eventDom).text()
            		evnt.id = $(eventDom).attr('id')
            		evnt.duration = $('duration',eventDom).text()
            		evnt.title = $('title',eventDom).text()
            		evnt.subtitle = $('subtitle',eventDom).text()
            		$('person',eventDom).each (index, personDom) =>
            			person = @typeaheadStrings.push($(personDom).text())
            			console.log($.inArray(person, @typeaheadStrings))
            			if person not in @typeaheadStrings
            				@typeaheadStrings.push($(personDom).text())

            		@typeaheadStrings.push(evnt.title)
            		@typeaheadStrings.push(evnt.title)
            		@events.push(evnt)
            async: true
        )



	resizeSidebar: () ->
		$('#sidebarContent').height($(window).height() - 80)
	

$(document).ready( ->
    top.fiveC3 = new FiveC3()
)
