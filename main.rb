require 'bencodr'
require 'net/http'
require 'digest/sha1'
require 'open-uri'
require 'macaddr'
require 'ipaddr'
require_relative 'client'
require_relative 'peer'

BEncodr.include!
torrent_file = ARGV[0]

client = Client.new({torrent_file: torrent_file})

client.run!
