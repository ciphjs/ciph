# Chiph documentation

## Messenger protocol

### Messages

```
{
    "id": "11111-123135135-2312",
    "client": 11111,
    "type": "message",
    "user_name": "Nick Iv",
    "user_id": "dev@nim579.ru",
    "data": "Hello world!"
}
```

### Types

#### message

Simple text message.

#### status

Send message status.

```
{
    "client": 11112,
    "type": "status",
    "user_name": "Nick Iv",
    "user_id": "dev@nim579.ru",
    "data": {
        "message_id": "11111-123135135-2312",
        "status": 0
    }
}
```

Statuses:
- `0` – received
- `1` — readed

**heartbeat**

Send status of participant.

```
{
    "client": 11111,
    "type": "heartbeat",
    "user_name": "Nick Iv",
    "user_id": "dev@nim579.ru"
    "data": null
}
```

## Crypted tunnel protocol

Message scheme (like URL): `ciph://{client}@{room_or_tunnel}/{method}?{data}`

Example: `ciph://11111@123124/message?m=1231kljlk1j23l1kji1j23o12j3o1i2j31o2i3j2oi3j2`
Example for tunnel: `ciph://tunnel/new_room`

### Tunnel methods

#### /connect

`ciph://tunnel/connect?client={client_id}`

Request tunnel server for connect. Server response message with method `/created`.
**client** paremeter not required. If necessary or **client** already exists, server sends new **client_id** with method ``/created`.

#### /created

`ciph://tunnel/created?client={client_id}`

Tunnel response after connection. Return **client** parameter.

### Chat methods

#### /hello

`ciph://{sender_id}@{receiver_id}/hello`

Announce client in room, after `/hello` from tunnel.

#### /ecdh

`ciph://{sender_id}@{receiver_id}/ecdh?k={pubkey}`

Send Diffie Hellman Alice data.

#### /m

`ciph://{sender_id}@{receiver_id}/m?m={crypted_message}`

Send crypted message.
