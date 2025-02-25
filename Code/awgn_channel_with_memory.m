function r = awgn_channel_with_memory(s, noise_power, a, b, Tb, fs)
    t = (0:length(s)-1) / fs;
    delta = t == 0;  
    delayed_delta = t == b * Tb;  
    
    h = a * delta + (1 - a) * delayed_delta;
    
    s_conv = conv(h, s, 'same');
    
    noise = sqrt(noise_power) * randn(size(s_conv));
    
    r = s_conv + noise;
end
