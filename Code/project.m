%% Audio to Digital Conversion
[x_t, fs] = audioread('project.wav');
duration = 8;
x_t = x_t(1:duration*fs);

n_bits = 8;
L = 2^n_bits;
mp = max(abs(x_t));

num_samples = fs * duration;
disp(['Sample rate: ', num2str(fs), ' Hz']);

% Normalize the audio signal
normalized_signal = x_t / mp;

% Quantize 
quantized_signal = round((normalized_signal + 1) * (L-1)/2);
quantized_signal = max(0, min(L-1, quantized_signal));

binary_signal = de2bi(quantized_signal, n_bits, 'left-msb');
binaryStream = binary_signal(:)';
%% BPSK Encoder - team 20.
a_bpsk = 1; 
bpsk_signal = 2 * binaryStream - a_bpsk;  

signal_power = 1; 
noise_power = var(normalized_signal);
SNR = signal_power / noise_power;
SNR_dB = 10 * log10(SNR);

disp(['SNR:', num2str(SNR)]);
disp(['Signal Power:', num2str(signal_power)]);
disp(['Noise Power:', num2str(noise_power)]);
disp(['SNR in dB:', num2str(SNR_dB)]);
%% Upsampling and Preparation for Line Coding
Ns = 8;
fs_tx = fs * Ns;      
bpsk_upsampled = zeros(1, length(bpsk_signal) * Ns);
bpsk_upsampled(1:Ns:end) = bpsk_signal;
Tb = 1 / fs;
t_symbol = (0:Ns-1) / fs_tx;
%% Line Coding with Rectangular and Raised Cosine Pulse
alpha = 0.35; % set high for better ISI
span = 8;     
t_pulse = (-span/2:(1/Ns):span/2) * Tb;  

rc_pulse = raised_cosine_pulse(t_pulse, Tb, alpha);
rc_pulse = rc_pulse / sum(rc_pulse) * Ns;
rect_pulse = ones(1, length(t_symbol));

bpsk_rect = filter(rect_pulse/sum(rect_pulse), 1, bpsk_upsampled);
bpsk_raised_cos = filter(rc_pulse/sum(rc_pulse), 1, bpsk_upsampled);

figure;
subplot(4,1,1);
plot(bpsk_rect);
title('BPSK with Rectangular Pulse Shaping');
xlabel('Sample Number');
ylabel('Amplitude');
xlim([1,1000]);

subplot(4,1,2);
plot(bpsk_raised_cos);
title('BPSK with Raised Cosine Pulse Shaping');
xlabel('Sample Number');
ylabel('Amplitude');
xlim([1,1000]); 

subplot(4,1,3);
plot(t_symbol, rect_pulse);
title('Rectangular Pulse');
xlabel('Time (s)');
% xlim([0,10^-6]);
ylabel('Amplitude');

subplot(4,1,4);
plot(t_pulse, rc_pulse);
title('Raised Cosine Pulse');
% xlim([0,10^-6]);
xlabel('Time (s)');
ylabel('Amplitude');
%% Modulation - Phase modulation
fc = 1000;
t_mod = (0:length(bpsk_rect)-1) / fs_tx;
carrier = cos(2 * pi * fc * t_mod);

rect_mod = bpsk_rect .* carrier;
rc_mod   = bpsk_raised_cos .* carrier;

t_conv = linspace(0, duration, length(rect_mod));

figure;
subplot(2,1,1);
plot(t_conv, rect_mod);
title('Rectangular Pulse Modulation');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t_conv, rc_mod);
title('Raised Cosine Pulse Modulation');
xlabel('Time (s)');
ylabel('Amplitude');
%% Channel
target_EbN0_dB = 10;  
target_EbN0 = 10^(target_EbN0_dB/10);
calc_noise_power = signal_power / target_EbN0;  

outp = 0.9;  
b = 0.1;    

% # Apply AWGN 
r_rect_memless = rect_mod + sqrt(calc_noise_power) * randn(size(rect_mod));
r_rc_memless = rc_mod + sqrt(calc_noise_power) * randn(size(rc_mod));

figure;
subplot(2,1,1);
plot(t_conv, r_rect_memless);
title('Received Signal - Rectangular without Memory');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t_conv, r_rc_memless);
title('Received Signal - Raised Cosine without Memory');
xlabel('Time (s)');
ylabel('Amplitude');
%% Constellation plots - channels
figure;
subplot(3,2,1);
plot(real(rect_mod), imag(rect_mod), 'bo');
title('Input Constellation Diagram (Rectangular)');
xlabel('In-phase');
ylabel('Quadrature');
axis([-2 2 -2 2]);
grid on;
axis square;

subplot(3,2,2);
plot(real(rc_mod), imag(rc_mod), 'bo');
title('Input Constellation Diagram (Raised Cosine)');
xlabel('In-phase');
ylabel('Quadrature');
axis([-2 2 -2 2]);
grid on;
axis square;

subplot(3,2,3);
plot(real(r_rect_memless), imag(r_rect_memless), 'ro');
title('Output Constellation Diagram (Rectangular, Memoryless)');
xlabel('In-phase');
ylabel('Quadrature');
axis([-2 2 -2 2]);
grid on;
axis square;

subplot(3,2,4);
plot(real(r_rc_memless), imag(r_rc_memless), 'ro');
title('Output Constellation Diagram (Raised Cosine, Memoryless)');
xlabel('In-phase');
ylabel('Quadrature');
axis([-2 2 -2 2]);
grid on;
axis square;
%% Demodulation
mixed_signal_rect = r_rect_memless .* carrier;
mixed_signal_rc   = r_rc_memless .* carrier;

lpFilt = designfilt('lowpassfir', 'PassbandFrequency', 500/(fs_tx/2), ...
    'StopbandFrequency', 600/(fs_tx/2), 'PassbandRipple', 1, ...
    'StopbandAttenuation', 60, 'DesignMethod', 'kaiserwin');

demodulated_rect = filtfilt(lpFilt, mixed_signal_rect);
demodulated_rc = filtfilt(lpFilt, mixed_signal_rc);

figure;
subplot(4,1,1);
plot(t_conv, mixed_signal_rect);
title('Mixed Signal - Rectangular');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,2);
plot(t_conv, demodulated_rect);
title('Filtered Signal - Rectangular');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,3);
plot(t_conv, mixed_signal_rc);
title('Mixed Signal - Raised Cosine');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,4);
plot(t_conv, demodulated_rc);
title('Filtered Signal - Raised Cosine');
xlabel('Time (s)');
ylabel('Amplitude');
%% Line Decoder
rect_filtered = filter(rect_pulse/sum(rect_pulse), 1, demodulated_rect);
delay_rect = floor(Ns/2);
symbol_indices_rect = delay_rect + (1:Ns:length(rect_filtered));
symbol_indices_rect = symbol_indices_rect(symbol_indices_rect <= length(rect_filtered));
rect_samples = rect_filtered(symbol_indices_rect);

rc_filtered = filter(rc_pulse/sum(rc_pulse), 1, demodulated_rc);
delay_rc = floor((span * Ns)/2);
symbol_indices_rc = delay_rc + (1:Ns:length(rc_filtered));
symbol_indices_rc = symbol_indices_rc(symbol_indices_rc <= length(rc_filtered));
rc_samples = rc_filtered(symbol_indices_rc);

figure;
subplot(2,1,1);
stem(rect_samples);
title('Sampled Line Decoded Signal (Rectangular)');
xlabel('Symbol Number');
ylabel('Amplitude');

subplot(2,1,2);
stem(rc_samples);
title('Sampled Line Decoded Signal (Full Raised Cosine)');
xlabel('Symbol Number');
ylabel('Amplitude');
%% BPSK Decoder
positive_samples_rect = rect_samples(rect_samples > 0);
negative_samples_rect = rect_samples(rect_samples <= 0);

if ~isempty(positive_samples_rect) && ~isempty(negative_samples_rect)
    threshold_rect = (mean(positive_samples_rect) + mean(negative_samples_rect))/2;
else
    threshold_rect = 0;
end

positive_samples_rc = rc_samples(rc_samples > 0);
negative_samples_rc = rc_samples(rc_samples <= 0);

if ~isempty(positive_samples_rc) && ~isempty(negative_samples_rc)
    threshold_rc = (mean(positive_samples_rc) + mean(negative_samples_rc))/2;
else
    threshold_rc = 0;
end

rect_decisions = rect_samples > threshold_rect;
rc_decisions = rc_samples > threshold_rc;

numSymbols = min([length(rect_decisions), length(rc_decisions), length(binaryStream)]);
rect_decisions = rect_decisions(1:numSymbols);
rc_decisions = rc_decisions(1:numSymbols);
binaryStream = binaryStream(1:numSymbols);

BER_rect = sum(rect_decisions ~= binaryStream) / numSymbols;
BER_rc = sum(rc_decisions ~= binaryStream) / numSymbols;

disp(['BER (Rectangular): ', num2str(BER_rect)]);
disp(['BER (Raised Cosine): ', num2str(BER_rc)]);

figure;
stem(rc_decisions(1:min(100,numSymbols)));
title('BPSK Decisions (Raised Cosine)');
xlabel('Symbol Index');
ylabel('Decision (0/1)');

figure;
stem(rect_decisions(1:min(100,numSymbols)));
title('BPSK Decisions (Rectangular)');
xlabel('Symbol Index');
ylabel('Decision (0/1)');
%% Digital to Audio Conversion - Comparing Original, RC, and Rectangular Reconstruction
numBitsReceived_rc = length(rc_decisions);
numBitsReceived_rect = length(rect_decisions);
numBitsExpected = floor(min(numBitsReceived_rc, numBitsReceived_rect) / n_bits) * n_bits;

rc_decisions_trimmed = rc_decisions(1:numBitsExpected);
dequantized_signal_rc = bi2de(reshape(rc_decisions_trimmed, [], n_bits), 'left-msb') - (L/2 - 1);
reconstructed_signal_rc = (dequantized_signal_rc * mp) / L;
reconstructed_signal_rc = reconstructed_signal_rc / max(abs(reconstructed_signal_rc));

rect_decisions_trimmed = rect_decisions(1:numBitsExpected);
dequantized_signal_rect = bi2de(reshape(rect_decisions_trimmed, [], n_bits), 'left-msb') - (L/2 - 1);
reconstructed_signal_rect = (dequantized_signal_rect * mp) / L;
reconstructed_signal_rect = reconstructed_signal_rect / max(abs(reconstructed_signal_rect));

figure;
subplot(3,1,1);
plot(x_t);
title('Original Audio Signal');
xlabel('Sample Number');
ylabel('Amplitude');

subplot(3,1,2);
plot(reconstructed_signal_rc);
title('Reconstructed Audio Signal (Raised Cosine)');
xlabel('Sample Number');
ylabel('Amplitude');

subplot(3,1,3);
plot(reconstructed_signal_rect);
title('Reconstructed Audio Signal (Rectangular)');
xlabel('Sample Number');
ylabel('Amplitude');
%% Saving Relevant Figures and Audio
output_folder = 'plots'; 
if ~exist(output_folder, 'dir')
    mkdir(output_folder); % Create folder if it doesn't exist
end

figHandles = findall(groot, 'Type', 'figure');
for i = 1:length(figHandles)
    figure(figHandles(i)); % Bring figure to foreground
    saveas(figHandles(i), fullfile(output_folder, sprintf('figure_%d.png', i))); % Save as PNG
end

audiowrite(fullfile(output_folder, 'reconstructed_rect.wav'), reconstructed_rect, fs);
audiowrite(fullfile(output_folder, 'reconstructed_rc.wav'),   reconstructed_rc,   fs);

disp('All figures saved in "plots" folder.');