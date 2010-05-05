#!/usr/local/bin/ruby
require 'time'

def check_reminder(event)
  now = Time.now
  beg = now - 180		# show for three minutes past due time
  if /\b(\d{1,2}:\d{1,2}(?:pm)?)\b\s*(?:\+(\d+))?/i =~ event
    ewhen = Time.parse $1
    if $2
      target = now + ($2.to_i * 60)
    else 
      target = now
    end
    puts event.sub(/^today\s+\d{4}\s\w+\s+\d+/,'Reminder:') if ((ewhen >= beg) && (ewhen <= target))
  end
end

# first, check the reminders calendar
reminders = `/usr/local/bin/when --calendar=~/.when/reminders --past=0 --future=0`.split("\n")[2..-1]
reminders.each {|event| check_reminder event } if reminders

# now, the main calendar
events = `/usr/local/bin/when --past=0 --future=0`.split("\n")[2..-1]
events.each {|event| check_reminder event } if events
