function p1_t = rectangular_pulse(t, pulse_width, pulse_height)
    p1_t = pulse_height .* (t >= 0) .* (t <= pulse_width);
end
