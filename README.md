# Matlab---OFDM--MIMO

This is a simple simulation for OFDM-MIMO system using Matlab's LTE commands.
In the default form of the code, it is implementing a 2x2 spatial multiplexing, i.e. different information symbols are being sent through Tx1 and Tx2.
Modifications can be made to switch to MRC/STC combinations.

The codes is divided to blocks and numbered from 1 to 9

# Important variables:
1) enb.NDLRB - the number of resource blocks (RB). min value is 6.
each RB hold 12 subcarries. so this is the the variable that determines the BW.

2) Tx_grid - the resource grid accomodating the transmitted symbols.
size(Tx_grid) = (enb.NDLRB*6,14,nTx). each column represents a single OFDM symbol. regular LTE frame holds 14 OFDM symbols.

3) txwave - the time domain modulated signal. each column is for a single Tx

4) rxwave - time domain signal at Rx
5) rxWaveform_noisy - the same rxwave but with added complex wgn

6) Rx_grid - the resource grid obtained at the Rx.

7) H_ideal - ideal channel frequency response.

# Things to notice:
1) Matlab's lteFadingChannel function implements a 7 samples delay regardless of any channel configuration. so at least 7 zeros are needed to pad the txwave.

2) channel.MIMOCorrelation - configures the correlation between the variables in the channel response H.
By default we use Matlabs configuration. lines 51-53 replaces the default configuration. one can play with the values in the matrices and note is affect on the values in H_ideal.

3) Notice again that in the defualt case of 2x2 spatial multiplexing we have that each bin in Rx_grid is a sum of 2 (probably different) symbols transmitted from Tx1 and Tx2 that went through different channels.
So for example, the following quantity should be low (less than -45db):

e = Rx_grid(:,3,1) - (Tx_grid(:,3,1).*H_ideal(:,3,1,1) + Tx_grid(:,3,2).*H_ideal(:,3,1,2) );
20*log10(rms(abs(e))/rms(abs(Rx_grid(:,3,1))))

