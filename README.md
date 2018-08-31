# Matlab---OFDM--MIMO

This is a simple simulation for OFDM-MIMO system using Matlab's LTE commands.
In the default form of the code, it is implementing a 2x2 spatial multiplexing, i.e. different information symbols are being sent through Tx1 and Tx2.
Modifications can be made to switch to MRC/STC combinations.

# Important variables:
1) Tx_grid - the resource grid accomodating the transmitted symbols.
size(Tx_grid) = [
