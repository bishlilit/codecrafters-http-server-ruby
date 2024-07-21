require "socket"

def handle_client_connection(client_socket) 
    raw_request = ""
    # raw_request = client_socket.read
    
    # while line = client_socket.gets # Read lines from socket
    #     raw_request += line
    # end
    # 
    
    while (line = client_socket.gets) != "\r\n"
        raw_request += line
    end
    
    puts "raw request: " +  raw_request
    puts "end of raw request"
    
    request_line = raw_request.split("\r\n")[0]
    
    puts "request line: " + request_line
    puts "end of request line"
    
    request_method = request_line.split(" ")[0].strip
    request_target = request_line.split(" ")[1] # url path
    request_headers = {}
    puts "gathering request headers..."
    puts "range: (" + "1" + " to " + (raw_request.split("\r\n").length() - 1).to_s + ")" 
    for header_index in 1..raw_request.split("\r\n").length() - 1 do    
        header_line = raw_request.split("\r\n")[header_index]
        puts "header_line: " + header_line
        seperator_index = header_line.index(':')
        puts "index: " + seperator_index.to_s
        key = header_line[0, seperator_index].strip
        puts "key: " + key
        value = header_line[seperator_index + 1, header_line.length].strip
        request_headers[key] = value
        puts header_index.to_s + ". key: " + key + ", value: " + value
    end
    puts "Finished gathering request headers..."
    
    status = ""
    response_body = ""
    response_headers = {}
    if request_target == "/" 
        status = "HTTP/1.1 200 OK"
    elsif request_target.start_with? "/echo"
        status = "HTTP/1.1 200 OK"
        content = request_target["/echo".length + 1..]
        puts "request target: " + request_target + ", content: " + content
        response_body = content
        response_headers["Content-Type"] = "text/plain"
    elsif request_target.start_with? "/user-agent"
        status = "HTTP/1.1 200 OK"
        content = request_headers["User-Agent"]    
        puts "request target: " + request_target + ", content: " + content
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
        response_headers_str += key + ": " + value + end_of_header
    end
    
    puts "response_headers_str: " 
    puts response_headers_str
    puts "--------------"
    
    puts "response: "
    puts status + end_of_status_line + response_headers_str + end_of_headers + response_body
    puts "--------------"
    
    client_socket.write(status + end_of_status_line + response_headers_str + end_of_headers + response_body)
    # client_socket.close_write    
end

# You can use print statements as follows for debugging, they'll be visible when running tests.
print("Logs from your program will appear here!")

# Uncomment this to pass the first stage
#
server = TCPServer.new("localhost", 4221)


# handle_client_connection(client_socket)
loop do 
    client_socket, client_address = server.accept

    puts
    puts "client connected"

    puts "creating a new thread"
    thr = Thread.new { handle_client_connection(client_socket) }
end
