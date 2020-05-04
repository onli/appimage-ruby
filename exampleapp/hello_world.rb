puts "hello world"

require 'parallel'
require 'ruby-progressbar'

Parallel.map(1..3, progress: "Doing stuff") { sleep 1 }