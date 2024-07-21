require "socket"

def get_raw_request(client_socket) 
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
    return raw_request
end

def get_request_headers(raw_request)
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
    return request_headers
end

def get_request_method(raw_request)
    request_line = raw_request.split("\r\n")[0]
    
    puts "request line: " + request_line
    puts "end of request line"
    
    request_method = request_line.split(" ")[0].strip
    return request_method
end

def get_request_target(raw_request)
    request_line = raw_request.split("\r\n")[0]
    
    puts "request line: " + request_line
    puts "end of request line"

    request_target = request_line.split(" ")[1] # url path
    return request_target
end

def handle_request(request_method, request_target, request_headers, config)
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
    elsif request_target.start_with? "/files"
        status = "HTTP/1.1 200 OK"
        filename = request_target["/files/".length, request_target.length]
        begin
            file = File.new(config["directory"] + filename, 'r')
            file_data = file.read
            response_body = file_data
            response_headers["Content-Type"] = "application/octet-stream"
        rescue Errno::ENOENT
            status = "HTTP/1.1 404 Not Found"
        end
    else
        status = "HTTP/1.1 404 Not Found"
    end 
    
    if response_body.length > 0 
        response_headers["Content-Length"] = response_body.length.to_s
    end
    puts "response headers length: " + response_headers.length.to_s
  

    return status, response_body, response_headers
end

def handle_response(client_socket, status, response_headers, response_body)
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
end

def handle_client_connection(client_socket, config) 
    raw_request = get_raw_request(client_socket)    
    request_headers = get_request_headers(raw_request)    
    request_method = get_request_method(raw_request)
    request_target = get_request_target(raw_request)
    
    status, response_body, response_headers = handle_request(request_method, request_target, request_headers, config)    
    
    handle_response(client_socket, status, response_headers, response_body)
end

def get_program_arguments
    config = {}
    ARGV.each_with_index {|val, index| 
        if val == "--directory" 
          config["directory"] = ARGV[index + 1]
        end
    }
    return config
end

config = get_program_arguments

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
    thr = Thread.new { handle_client_connection(client_socket, config) }
end
