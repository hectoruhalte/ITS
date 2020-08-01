#!/bin/bash
#\
exec tclsh "$0" "$@"
set R 6371000;
set lat_1 [lindex $argv 0];
set lon_1 [lindex $argv 1];
set lat_2 [lindex $argv 2];
set lon_2 [lindex $argv 3];
set h [expr sqrt ([expr [expr pow(sin([expr [expr $lat_1 - $lat_2] / 2]),2)] + \
	[expr pow(sin([expr [expr $lon_1 - $lon_2] / 2]),2) * cos($lat_1) * cos($lat_2)]])];
set distancia [expr asin($h) * 2 * $R];
puts $distancia;
