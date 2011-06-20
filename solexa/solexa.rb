#! /usr/bin/env ruby

lib_path = File.join(File.expand_path(File.dirname(__FILE__)), "lib")
$:.unshift lib_path

require 'rubygems'
require 'solexa'


Solexa::App.start


