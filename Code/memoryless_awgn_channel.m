function r = memoryless_awgn_channel(s, noise_power)
    noise = sqrt(noise_power) * randn(size(s));
    r = s + noise;
end