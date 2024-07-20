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
response_body = ""
response_headers = {}
if request_target == "/" 
    status = "HTTP/1.1 200 OK"
elsif request_target.start_with? "/echo"
    status = "HTTP/1.1 200 OK"
    content = request_target["/echo".length + 1..]
    puts content
    response_body = content
    response_headers["Content-Type"] = "text/plain"
else
    status = "HTTP/1.1 404 Not Found"
end 


if response_body.length > 0 
  response_headers["Content-Length"] = response_body.length.to_s
end
puts "response headers length: " + response_headers.length.to_s


end_of_status_line = "\r\n"
response_headers_str = ""
end_of_headers = "\r\n"

end_of_header = "\r\n"
response_headers.each do |key, value|
    response_headers_str += key + ":" + value + end_of_header
end

puts "response_headers_str: " + response_headers_str

client_socket.write(status + end_of_status_line + response_headers_str + end_of_headers + response_body)
