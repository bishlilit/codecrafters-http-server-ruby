require "socket"

# You can use print statements as follows for debugging, they'll be visible when running tests.
print("Logs from your program will appear here!")

# Uncomment this to pass the first stage
#
server = TCPServer.new("localhost", 4221)
client_socket, client_address = server.accept


endOfStatusLine = "\r\n"
header = ""
endOfHeaders = "\r\n"
client_socket.write("HTTP/1.1 200 OK" + endOfStatusLine + endOfHeaders)
