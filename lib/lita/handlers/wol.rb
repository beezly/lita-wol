require 'wol'

module Lita
  module Handlers
    class Wol < Handler
      route(/^wol\s+wake\s+(([0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2})|([^\s]*))/i, :wake,     help: { "wol wake (<mac_address>|<alias>)" => "Sends a wake-on-lan packet to <mac_address>" })
      route(/^wol\s+add\s+([^\s]+)\s+([0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2})/i,  :add_host, help: { "wol add <host> <mac_address>" => "Create an alias <host> for <mac_address>" })
      route(/^wol\s+delete\s([^\s]+)/i,                                                                             :del_host, help: { "wol delete <host>" => "Deletes an alias" })
      route(/^wol\s+list/i,                                                                                        :list,     help: { "wol list" => "Lists host aliases" })
      
      def wake(response) 
        mac_address = response.matches[0][1]
        host = response.matches[0][2]
        mac_address = redis.get(host) if (host != "") 
        if mac_address == "" 
          response.reply "Could not find mac_address"
        else
          wol=::Wol::WakeOnLan.new(mac: mac_address).wake
          response.reply "Sent wake-on-lan packet to #{mac_address}"
        end
      end

      def add_host(response)
        host = response.matches[0][0]
        mac_address = response.matches[0][1]
        redis.set(host, mac_address)
        response.reply "Defined #{host} as #{mac_address}"
      end

      def del_host(response)
        host = response.matches[0][0]
        number_deleted = redis.del(host)
        response.reply "Deleted #{number_deleted} entries"
      end

      def list(response)
        aliases = redis.keys
        aliases.each { |k| response.reply "Alias #{k} #{redis.get(k)}" }  
      end

    end

    Lita.register_handler(Wol)
  end
end
