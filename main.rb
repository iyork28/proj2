require 'bencodr'
require 'net/http'
require 'digest/sha1'
require 'open-uri'
require 'macaddr'
require 'ipaddr'
require 'socket'

require_relative 'client'
require_relative 'peer'
require_relative 'handshake_response'
require_relative 'message_handler'
require_relative 'block'
require_relative 'block_queue'

BEncodr.include!
torrent_file = ARGV[0]

client = Client.new({torrent_file: torrent_file})

client.run!
