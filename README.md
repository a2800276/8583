### ISO 8583 Financial Messaging for Ruby

This package currently contains code for coding an decoding ISO 8583
Financial Message.

###### Include the following features:

  1. Support for 128 bits bitmap .
  2. Hexadecimal bitmaps.
  3. Mandatory fields.
  4. Beautiful message dumps for developer happiness.

## Usage

The best place to understand what this library has to offer is reading the
[message.rb](https://github.com/MaG21/8583/blob/master/lib/iso8583/message.rb)
file. However, one can use it like so:

#### Create defs
```ruby
class CustomMessage < ISO8583::Message
        include ISO8583

        mti_format N, :length => 4
        mti 100, "Authorization Request Acquirer Gateway"
        mti 110, "Authorization Request Response Issuer Gateway"

        bmp  2, "Primary Account Number (PAN)",               LLVAR_N,   :max    => 19
        bmp  3,  "Processing Code",                           N,         :length =>  6
        bmp  4,  "Amount (Transaction)",                      N,         :length => 12
        bmp  5,  "Amount, Reconciliation" ,                   N,         :length => 12
        bmp  6,  "Amount, Cardholder Billing" ,               N,         :length => 12

        bmp 65, "new bitmap", LLVAR_ANS, :max => 99
end
```

Once you've defined the fields you'll be using, then you can proceed to create
your messages.

#### Build Message
```ruby
msg = CustomMessage.new(nil)

msg.mti = 100
msg[3]  = 3
msg[4]  = 4
msg[5]  = 5
msg[6]  = 6
msg[65] = 'STRING'

puts msg
```
######Output:

```text
MTI:100 (Authorization Request Acquirer Gateway)

003            Processing Code : 3
004       Amount (Transaction) : 4
005     Amount, Reconciliation : 5
006 Amount, Cardholder Billing : 6
065                 new bitmap : STRING
```

#### ISO
```ruby
iso = msg.to_b
p iso
```

###### Output
```text
"0100\xBC\x00\x00\x00\x00\x00\x00\x00\x80\x00\x00\x00\x00\x00\x00\x0000000300000000000400000000000500000000000606STRING"
```

#### Parse Message
```ruby
parsed = CustomMessage.parse(iso)
puts parsed
```
###### Output

```text
MTI:100 (Authorization Request Acquirer Gateway)

003            Processing Code : 3
004       Amount (Transaction) : 4
005     Amount, Reconciliation : 5
006 Amount, Cardholder Billing : 6
065                 new bitmap : STRING
```

## Dumps

The alignment is set to 16 characters by default.

```ruby
# ...
puts message.dump
```
sample output:

```text
  01  00  72  38  01  00  04  C5  00  14  04  12  34  10  00  00  ..r8........4...
  00  00  00  00  00  07  28  09  46  28  00  00  23  09  46  01  ......(.F(..#.F.
  28  00  03  31  32  33  34  35  36  30  30  30  30  36  35  39  (..1234560000659
  31  32  33  34  35  36  37  38  39  30  31  32  33  34  35  00  123456789012345.
  32  38  31  37  00  02  31  32  00  11  4E  43  20  32  2E  33  2817..12..NC 2.3
  34  2D  72  33  00  09  31  32  33  34  35  36  37  38  39      4-r3..123456789
```
  
Although, one can set a different alignment!

```ruby
# ...
# 8 characters alignment
puts message.dump(8)
```
sample output:

```text
  01  00  72  38  01  00  04  C5  ..r8....
  14  04  12  34  10  00  00  52  ...4...R
  00  00  00  00  07  28  09  46  .....(.F
  00  00  23  09  46  01  07  28  ..#.F..(
  03  31  32  33  34  35  36  30  .1234560
  30  30  36  35  39  39  31  32  00659912
  34  35  36  37  38  39  30  31  45678901
  33  34  35  00  04  32  38  31  345..281
  00  02  31  32  00  11  4E  43  ..12..NC
  32  2E  33  2E  34  2D  72  33  2.3.4-r3
  09  31  32  33  34  35  36  37  .1234567
  39                              9
```
