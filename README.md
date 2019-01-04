# Assembly-Fun

Assembly programs written for the DE1-SoC board (Cortex-A9). Just a sample to show case my abilities. It would be neat to factor some of these programs so that it works with my 8-bit breadboard computer https://github.com/vtotient/8-Bit-Computer.
I have purposely left out the boilerplate code that is needed to actually run this program on the DE1 board. 

### binary_search.s
This program implements a binary search algorithm.

### sample_isr.s
When KEY0 on the DE1 board is pushed, the current process is interuppted and this isr routine is performed (Light LEDs).

### blocked.s
Implements blocked matrix multiplication. More optimal than simple matrix multiplication. An example of when writing Assembly 
is more advantageous than writing C.
