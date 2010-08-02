#!/usr/bin/env ruby
#
# Script to handle iCal attachments for mutt
#
# If the appontment is accepted, it will also
# be added to the when calendar.
#
# attachment should be passed as an argument
#
require "optparse"

system "clear"

identity = ''
optparse = OptionParser.new do |opts|
  opts.banner = 'usage: icalmutt.rb -i identity icalfile'

  opts.on('-i', '--identity email', 'Specify which responder you are') do |email|
    identity = email
  end
end

begin
  optparse.parse!
rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
  $stderr.puts e
  $stderr.puts optparse
  exit 1
end

files = ARGV.join  ' '
system "icalview.rb #{files}"

begin
  print "(a)ccept, (d)ecline, (t)entative, (n)ot now: "
  choice = ($stdin.gets || 'n').chomp.downcase
rescue Interrupt
  choice = 'n'
end until /^[adtn]$/ =~ choice

if choice != 'n'
  print "Message [none]: "
  msg = ($stdin.gets || '').chomp.gsub /'/ , ''	# protect the command line
  if choice == 'a'
    puts "Adding event to ~/.when/calendar"
    system "ical2when.rb #{files} >> ~/.when/calendar"
  end
  org = `icalorg.rb #{files}`
  puts "Sending response to organizer: #{org}"
  desc = {'a' => "accepted", 'd' => "declined", 't' => "tentative"}
  tmpfile = `mktemp /tmp/ical.XXXXXX`.chomp
  system "icalrespond.rb -#{choice} -i #{identity} #{msg.length > 0 ? "-m '#{msg}'" : ''} #{files} > #{tmpfile}"
  system "mv #{tmpfile} #{tmpfile}.ics"	# so mutt guesses the content type
  system "echo 'Meeting attendance #{desc[choice]}\n\n#{msg}' | mutt -s 'Meeting response' -a #{tmpfile}.ics -- '#{org}'"

  File.delete "#{tmpfile}.ics"
end
