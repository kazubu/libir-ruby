require "mkmf"
dir_config('wiringPi')
if have_header('wiringPi.h') && have_library('wiringPi')
  create_makefile("IR")
end
