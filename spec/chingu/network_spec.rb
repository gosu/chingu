# frozen_string_literal: true

require "spec_helper"

def data_set
  {
    "a Hash" => [{ foo: :bar }],
    "a String" => ["Woof!"],
    "an Array" => [[1, 2, 3]],
    "a stream of packets" => [{ foo: :bar }, "Woof!", [1, 2, 3]],
    "huge packet" => [[:frogspawn] * 1000],
    "100 small packets" => 100.times.map { rand(100_000) }
  }
end

describe "Network" do
  describe Chingu::GameStates::NetworkServer do
    it "opens listening port on #start" do
      @server = described_class.new(address: "0.0.0.0", port: 9999)
      expect(@server).to receive(:on_start)

      @server.start
      @server.stop
    end

    it "client timeouts when connecting to blackhole IP" do
      @client = Chingu::GameStates::NetworkClient.new(address: "1.2.3.4",
                                                      port: 1234,
                                                      debug: true)
      @client.connect

      expect(@client).to receive(:on_timeout)

      @client.update while @client.socket
    end

    it "calls #on_start_error if failing" do
      @server = described_class.new(address: "1.2.3.999",
                                    port: 12_345_678) # crazy address:port
      expect(@server).to receive(:on_start_error)

      @server.start
      @server.stop
    end

    it "calls #on_connect and #on_disconnect when client connects" do
      @server = described_class.new(address: "0.0.0.0", port: 9999)
      @client = Chingu::GameStates::NetworkClient.new(address: "127.0.0.1",
                                                      port: 9999)

      expect(@server).to receive(:on_start)
      expect(@server).to receive(:on_connect).with(an_instance_of(TCPSocket))
      expect(@client).to receive(:on_connect)

      @server.start
      @client.connect

      @client.update until @client.connected?
      @server.update

      @client.stop
      @server.stop
    end
  end

  describe Chingu::GameStates::NetworkClient do
    describe "#connect" do
      it "callbacks #on_connection_refused when connecting to closed port" do
        @client = described_class.new(address: "127.0.0.1",
                                      port: 55_421) # Assume its closed
        expect(@client).to receive(:on_connection_refused)

        @client.connect
        5.times { @client.update }
      end

      it "does not callbacks #on_timeout when unable to connect for less time " \
         "than the timeout" do
        @client = described_class.new(address: "127.0.0.1",
                                      port: 55_421,
                                      timeout: 250) # Assume its closed
        @client.connect
        expect(@client).not_to receive(:on_timeout)

        5.times do
          @client.update
          sleep 0.01
        end
      end

      it "callbacks #on_timeout when unable to connect longer than the timeout" do
        @client = described_class.new(address: "127.0.0.1",
                                      port: 55_421,
                                      timeout: 250) # Assume its closed
        @client.connect
        @client.update

        sleep 0.3

        expect(@client).to receive(:on_timeout)
        5.times { @client.update }
      end
    end
  end

  describe "Connecting" do
    before do
      @client = Chingu::GameStates::NetworkClient.new(address: "127.0.0.1",
                                                      port: 9999)
      @server = Chingu::GameStates::NetworkServer.new(port: 9999)
    end

    it "connects to the server, when the server starts before it" do
      # TODO
      # @server.start
      # @client.connect
      # 5.times { @client.update }
      # @client.should be_connected
    end

    it "connects to the server, even when the server isn't initialy available" do
      @client.connect

      # FIXME: Is this really necessary?
      # 3.times { @client.update; sleep 0.2; @server.update; @client.flush }

      @server.start

      3.times do
        @client.update
        sleep 0.2
        @server.update
        @client.flush
      end

      expect(@client.connected?).to be_truthy
    end

    after do
      @client.close
      @server.close
    end
  end

  describe "Network communication" do
    before do
      @server = Chingu::GameStates::NetworkServer.new(port: 9999).start

      @client = Chingu::GameStates::NetworkClient.new(address: "127.0.0.1",
                                                      port: 9999).connect
      @client2 = Chingu::GameStates::NetworkClient.new(address: "127.0.0.1",
                                                       port: 9999).connect
      @client.update until @client.connected?
      @client2.update until @client2.connected?
    end

    after do
      @server.close
      @client.close
      @client2.close
    end

    describe "From client to server" do
      data_set.each do |name, data|
        it "must send/recv #{name}" do
          data.each do |packet|
            expect(@server).to receive(:on_msg).with(an_instance_of(TCPSocket),
                                                     packet)
            @client.send_msg(packet)
          end

          5.times { @server.update }
        end
      end
    end

    describe "From server to a specific client" do
      data_set.each do |name, data|
        it "must send/recv #{name}" do
          data.each { |packet| expect(@client).to receive(:on_msg).with(packet) }

          @server.update # Accept the client before sending, so we know of
          # its socket.
          data.each { |packet| @server.send_msg(@server.sockets[0], packet) }

          5.times { @client.update }
        end
      end
    end

    describe "From server to all clients" do
      data_set.each do |name, data|
        it "must send/recv #{name}" do
          @server.update # Accept the clients, so we know about their existence
          # to broadcast.

          data.each do |packet|
            expect(@client).to receive(:on_msg).with(packet)
            expect(@client2).to receive(:on_msg).with(packet)

            @server.broadcast_msg(packet)
          end

          5.times do
            @client.update
            @client2.update
          end
        end
      end
    end

    describe "Byte and packet counters" do
      before do
        @packet = "Hello! " * 10
        @packet_length = Marshal.dump(@packet).length
        @packet_length_with_header = @packet_length + 4
      end

      it "is zeroed initially" do
        [@client, @client2, @server].each do |network|
          expect(network.packets_sent).to eq(0)
          expect(network.bytes_sent).to eq(0)
          expect(network.packets_received).to eq(0)
          expect(network.bytes_received).to eq(0)
        end
      end

      describe "Client to server" do
        before do
          @client.send_msg(@packet)
          @server.update
        end

        describe "Client" do
          it "increments counters correctly when sending a message" do
            expect(@client.packets_sent).to eq(1)

            expect(@client.bytes_sent).to eq(@packet_length_with_header)
          end
        end

        describe "Server" do
          it "increments counters correctly when receiving a message" do
            expect(@server.packets_received).to eq(1)
            expect(@server.bytes_received).to eq(@packet_length_with_header)
          end
        end
      end

      describe "Server to client" do
        before do
          @server.update
          @server.send_msg(@server.sockets[0], @packet)
          @client.update
        end

        describe "Server" do
          it "increments sent counters" do
            expect(@server.packets_sent).to eq(1)
            expect(@server.bytes_sent).to eq(@packet_length_with_header)
          end
        end

        describe "Client" do
          it "increments received counters" do
            expect(@client.packets_received).to eq(1)
            expect(@client.bytes_received).to eq(@packet_length_with_header)
            expect(@client2.packets_received).to eq(0)
            expect(@client2.bytes_received).to eq(0)
          end
        end
      end

      describe "Server to clients" do
        before do
          @server.update
          @server.broadcast_msg(@packet)

          @client.update
          @client2.update
        end

        describe "Server" do
          it "increments sent counters" do
            # Single message, broadcast to two clients.
            expect(@server.packets_sent).to eq(2)
            expect(@server.bytes_sent).to eq(@packet_length_with_header * 2)
          end
        end

        describe "Clients" do
          it "increments received counters" do
            [@client, @client2].each do |client|
              expect(client.packets_received).to eq(1)
              expect(client.bytes_received).to eq(@packet_length_with_header)
            end
          end
        end
      end
    end
  end
end
