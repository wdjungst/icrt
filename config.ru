require File.expand_path(File.dirname(__FILE__) + '/icrt')

use Rack::StaticCache, :urls => ['/images'], :root => Dir.pwd + '/public'
run ICRT.new
