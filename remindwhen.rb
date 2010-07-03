#!/usr/local/bin/ruby
require 'time'

def check_reminder(event)
  now = Time.now
  beg = now - 180		# show for three minutes past due time
  if /\b(\d{1,2}:\d{1,2}(?:pm)?)\b(\s*\+(\d*)(q)?)?/i =~ event
    ewhen = Time.parse $1
    if $3
      target = now + ($2.to_i * 60)
    else 
      target = now
    end
    sound = !$4		# no q option
    qual = $2 || ''	# all qualifiers
    if ((ewhen >= beg) && (ewhen <= target))
      puts event.sub(/^today\s+\d{4}\s\w+\s+\d+/,'Reminder:').sub(qual,'')
      if sound
	wav = File.expand_path("~/.when/reminder.wav")
	system "mplayer -quiet #{wav} >/dev/null 2>&1" if File.exists? wav
      end
    end
  end
end

# first, check the reminders calendar
reminders = `/usr/local/bin/when --calendar=~/.when/reminders --nopaging --wrap=0 --past=0 --future=0`.split("\n")[2..-1]
reminders.each {|event| check_reminder event } if reminders

# now, the main calendar
events = `/usr/local/bin/when --nopaging --wrap=0 --past=0 --future=0`.split("\n")[2..-1]
events.each {|event| check_reminder event } if events
