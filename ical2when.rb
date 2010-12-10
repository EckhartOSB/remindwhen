#!/usr/bin/env ruby
#
# Converts an iCalendar to a when/remindwhen entry
#
require "rubygems"
require "icalendar"
require "date"

cals = Icalendar.parse($<)
cals.each do |cal|
  cal.events.each do |event|
    puts "#{(event.dtstart.offset == 0 ?
    		DateTime.parse(event.dtstart.strftime("%a %b %d %Y, %H:%M ") + event.dtstart.icalendar_tzid) : 
		event.dtstart).new_offset(Time.now.utc_offset/(24*60*60).to_f).strftime("%Y %b %d, %H:%M")}" +
    	 event.alarms.inject(" ") { |r,alarm| /-PT(\d+)M/ =~ alarm.trigger ? "+#{$1} " : r } +
    	 event.summary
  end
end
