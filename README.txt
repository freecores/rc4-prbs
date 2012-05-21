Hi,

I was looking for a quick implementation of RC4 and I couldn't find one, so I wrote one based on the wikipedia example.

It's quite easy to use:

1) First, issue rst
2) Load the password byte-by-byte into the password_input port. The lenght of the password is KEY_SIZE
3) Issue 768 clocks to perform key expansion
4) Now you should start receiving the pseudo-random stream via the output bus, one byte per clock. To encrypt or decrypt using RC4 you simply xor your data with the output stream.
Also you shouldn't use the first kb of stream because of a known RC4 vulnerability, so please discard those bytes.

The testbench and makefile work using icarus verilog and you can peer into rc4_tb.v to see an example implementation. 

After installing icarus verilog in your path, just issue:

make

and then

./rc4.vvp

And you should see the output of the simulation.

Any question or suggestion send an email to aortega@alu.itba.edu.ar

Cheers,

Alfredo
