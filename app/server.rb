require "socket"

# You can use print statements as follows for debugging, they'll be visible when running tests.
print("Logs from your program will appear here!")

# Uncomment this to pass the first stage
#
server = TCPServer.new("localhost", 4221)
client_socket, client_address = server.accept

puts
puts "client connected"

raw_request = client_socket.gets

puts 
puts "raw request: " +  raw_request

request_line = raw_request.split("\r\n")[0]

puts "request line: " + request_line

request_method = request_line.split(" ")[0].strip!
request_target = request_line.split(" ")[1] # url path

status = ""
if request_target == "/" 
    status = "HTTP/1.1 200 OK"
else
    status = "HTTP/1.1 404 Not Found"
end 

endOfStatusLine = "\r\n"
response_headers = ""
endOfHeaders = "\r\n"
client_socket.write(status + endOfStatusLine + response_headers + endOfHeaders)
