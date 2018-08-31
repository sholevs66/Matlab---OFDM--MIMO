clc;
close all;
clear all;

%% generating a single LTE OFDM frame - QPSK

%% 1) Tx config for single LTE OFDM frame
nTx = 2;
enb.CyclicPrefix = 'Normal';    
enb.NDLRB = 6;                  % number of resource blocks spanning the available BW, each RB should accomodate 12 subcarriers [6:..]
enb.CellRefP = nTx;             % number of Tx antennas
enb.NCellID = 1;                % to check.
enb.DuplexMode = 'FDD';
antPort = 0;
Tx_grid = lteDLResourceGrid(enb);   
 

%% 2) data and pilots
% pilots
tx_pilots_symbol = repmat(lteSymbolModulate([0;0],'QPSK'), [size(Tx_grid, 1), 1]);
tx_pilots_symbol = repmat(tx_pilots_symbol,[1,1,nTx]);
Tx_grid(:,1,:) = tx_pilots_symbol;                                          % insert pilots


% random data - spatial multiplexing: different data on each Tx
numberOfBits = size(Tx_grid,1)*size(Tx_grid,2)*nTx*2;                       % number of bits required is the number of slots in the txgrid times the number of bits required by constellation (2-QPSK, 4-16QAM, etc)
tx_data_bits = randi([0 1], numberOfBits, 1);
tx_data_symbols = lteSymbolModulate(tx_data_bits,'QPSK');                   % Modulation scheme, specified as 'BPSK', 'QPSK', '16QAM', '64QAM', or '256QAM'.
tx_data_symbols = reshape(tx_data_symbols, [size(Tx_grid,1),size(Tx_grid,2),size(Tx_grid,3)]);
Tx_grid(:,2:end,:) = tx_data_symbols(:,1:end-1,:);                          % insert randomized data symbols


%% 3) get time signals
[txwave,info] = lteOFDMModulate(enb,Tx_grid);


%% 4) channel model parameters
channel.ModelType = 'GMEDS';                        % The Rayleigh fading is modeled using the Generalized Method of Exact Doppler Spread, defualt and reccomended is GMEDS
channel.DelayProfile = 'EPA';                       % fading type: 'EPA', 'EVA', 'ETU', 'Custom', 'Off'
channel.DopplerFreq = 0;                            % Maximum Doppler frequency, in Hz.
channel.MIMOCorrelation = 'Medium';                 % Correlation between UE and eNodeB antennas: 'Low', 'Medium', 'UplinkMedium', 'High', 'Custom'
channel.NRxAnts = 2;                                % number of Rx antennas
channel.InitTime = 0;
channel.InitPhase = 'Random';                       % channel.InitPhase = 'Random';
channel.Seed = 100;                                   
channel.NormalizePathGains = 'On';
channel.NormalizeTxAnts = 'On';
channel.SamplingRate = info.SamplingRate;
channel.NTerms = 16;

% channel.MIMOCorrelation = 'Custom'; 
% channel.TxCorrelationMatrix = [1,0.99;0.99,1];             % nTx, nTx matrix, specifying correlation between tx antennas
% channel.RxCorrelationMatrix = [1,0.99;0.99,1];               % An NRxAnts-by-NRxAnts complex matrix specifying the correlation between each of the receive antennas.

%% 5) transmit signal 
[rxwave, channel_info] = lteFadingChannel(channel,[txwave;zeros(7,nTx)]);  
      
        
%% 6) Noise config
SNRdB = 22;
SNR = 10^(SNRdB/20);                                                    % linear SNR
N0 = 1/(sqrt(2.0*enb.CellRefP*double(info.Nfft))*SNR);                  % noise gain
noise = N0*complex(randn(size(rxwave)),randn(size(rxwave)));            % noise vector
% Add noise to the received time domain waveform
rxWaveform_noisy = rxwave + noise;


%% 7) time offset estimate
offset = lteDLFrameOffset(enb,rxwave);
offset = 7;        
rxwave = rxwave(1+offset:end,:);
rxWaveform_noisy = rxWaveform_noisy(1+offset:end,:);

%% 8) demodulate the rx signal and the rx+noise signal
Rx_grid = lteOFDMDemodulate(enb,rxwave);
Rx_grid_noisy = lteOFDMDemodulate(enb,rxWaveform_noisy);

%% 9) channel response
[H_ideal] = lteDLPerfectChannelEstimate(enb,channel,[offset,0]);        % [RB*12, 14, nRx, nTx]


fprintf('done simulation');
