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
Example for tunnel: `ciph://11111@tunnel/new_room`

### Tunnel methods

#### /new_room

Request tunnel server for create new room. Server response message with method `/hello`.

#### /connect_room

`ciph://11111@tunnel/connect_room?id={room_id}`

Request tunnel server for connect to room. Server response message with method `/hello`.

### Room methods

#### /hello

`ciph://11111@{room_id}/hello`

Response from tunnel, if you connected to some room

#### /dh_a

`ciph://11111@{room_id}/dh_a?g={prime}&p={generator}&a={pubkey}`

Send Diffie Hellman Alice data.

#### /dh_b

`ciph://11111@{room_id}/dh_b?b={pubkey}`

Send Diffie Hellman Bob data.

#### /m

`ciph://11111@{room_id}/m?m={crypted_message}`

Send crypted message.
