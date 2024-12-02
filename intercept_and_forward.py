import socket
import threading

def intercept_and_forward(listen_host, listen_port, remote_host, remote_port):

    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((listen_host, listen_port))
    server_socket.listen(5)
    print(f"[+] Listening on {listen_host}:{listen_port}...")

    while True:
        client_socket, client_address = server_socket.accept()
        print(f"[+] Connection from {client_address}")

        thread = threading.Thread(target=handle_client, 
                                args=(client_socket, remote_host, remote_port)
        )
        thread.start()

def handle_client(client_socket, remote_host, remote_port):
    try:
        # Connect to the remote host
        remote_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        remote_socket.connect((remote_host, remote_port))
        print(f"Connected to remote host {remote_host}:{remote_port}")

        # Start threads to handle communication in both directions
        client_to_remote_thread = threading.Thread(target=forward_data, 
                                args=(client_socket, remote_socket)
        )
        remote_to_client_thread = threading.Thread(target=forward_data, 
                                args=(remote_socket, client_socket)
        )

        client_to_remote_thread.start()
        remote_to_client_thread.start()

        # Wait for both threads to finish
        client_to_remote_thread.join()
        remote_to_client_thread.join()

    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Close both sockets
        client_socket.close()
        remote_socket.close()


def forward_data(source_socket, destination_socket):
    try:
        while True:
            data = source_socket.recv(4096)
            if not data:
                break

            # Inspect and modify the data if needed
            print(f"Received data: {data.decode('utf-8', errors='ignore')}")
            modified_data = modify_data(data)
            print(f"Modified data: {modified_data.decode('utf-8', errors='ignore')}")

            # Forward the data to the destination socket
            destination_socket.sendall(modified_data)

    except Exception as e:
        print(f"Forwarding error: {e}")
    finally:
        source_socket.close()
        destination_socket.close()

def modify_data(data):
    data = data.replace(b"HELLO", b"WORLD")
    return data


if __name__ == "__main__":
    LISTEN_HOST = "10.0.2.15"
    LISTEN_PORT = 8080

    REMOTE_HOST = "10.0.2.15"
    REMOTE_POST = 9878

    intercept_and_forward(LISTEN_HOST, LISTEN_PORT, REMOTE_HOST, REMOTE_POST)
