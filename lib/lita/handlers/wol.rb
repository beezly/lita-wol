require 'wol'

module Lita
  module Handlers
    class Wol < Handler
      route(/^wake\s+([0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2}:[0-9a-f]{2})/i, :wake, help: { "wake <mac_address>" => "Sends a wake-on-lan packet to <mac_address>" })
      
      def wake(response) 
        mac_address = response.matches[0][0]
        wol=::Wol::WakeOnLan.new(mac: mac_address)
        wol.wake
        response.reply "Sent wake-on-lan packet to #{mac_address}"
      end

    end

    Lita.register_handler(Wol)
  end
end
