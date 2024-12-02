import datetime
import sys
import socket

SOH_BIN = "\x01"
SOH_UNI = "|"

# Paste an example LOGON FIX message for the system being tested here. 
MESSAGE_TEMPLATE = b""

def str_to_bytestr(value):
    return bytes(value, "utf-8")


def bytes_to_ascii(string):
    return string.decode("unicode_escape")


def msg_str_update_field(message, name, value):
    msg_fields = message.split(SOH_UNI)
    for i, field in enumerate(msg_fields):
        if field.startswith(f"{name}="):
            msg_fields[i] = f"{name}={value}"
            break

    new_message = SOH_UNI.join(msg_fields)

    return new_message


def msg_str_calc_time(offset=0):
    t = datetime.now()
    t = t - timedelta(hours=offset)
    t = t.strftime("%Y%m%d-%H:%M:%S")
    t = str(t) + "." + str(round(time.time()* 100))[-3:]

    return t


def msg_str_calc_length(message):
    msg_fields = message.split(SOH_UNI)
    length = len(SOH_UNI.join(msg_fields[2:-2]) + SOH_UNI)

    return length


def msg_str_calc_chksum(message):
    checksum = 0
    message = message.replace(SOH_UNI, SOH_BIN)
    for c in message[:message.index(f"{SOH_BIN}10=")]:
        checksum += ord(c)
    checksum = str((checksum % 256) + 1).zfill(3)

    return checksum


def update_message(message, field, value):
    # Update message field
    new_msg = msg_str_update_field(
        bytes_to_ascii(MESSAGE_TEMPLATE), field, value
    )

    # Update message length
    new_msg = msg_str_update_field(
        new_msg,  "9", msg_str_calc_length(new_msg)
    )
    # Update message checksum
    new_msg = msg_str_update_field(
        new_msg, "10", msg_str_calc_chksum(new_msg)
    )

    return new_msg


def main():
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <IP ADDRESS> <PORT> <DICT FILE>")
        print(f"Example: python {sys.argv[0]} 127.0.0.1 8450 senderIDs.txt")
        sys.exit(1)

    server = str(sys.argv[1])
    port = int(sys.argv[2])
    dict_file = sys.argv[3]

    f = open(dict_file, "r")
    for line in f.readlines():
        senderId = line.strip()

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((server, port))

        msg = update_message(MESSAGE_TEMPLATE, "34", "1")
        msg = update_message(msg, "49", senderId)

        msg = str_to_bytestr(msg.replace(SOH_UNI, SOH_BIN))
        s.send(msg)
        print(f"[+] Test: {senderId}")
        print(f"OUT: {msg.replace(b'\x01', b'|')}")

        data = s.recv(1024)
        print(f" IN: {data.replace(b'\x01', b'|')}\n")

        s.close()


    f.close()
    sys.exit(0)



if __name__ == "__main__":
    main()
