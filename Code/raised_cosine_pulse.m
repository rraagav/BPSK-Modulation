% Define true raised cosine function
function p = true_raised_cosine(t, T, alpha)
    % Initialize pulse array
    p = zeros(size(t));
    
    % Handle the special case at t=0
    p(t == 0) = 1;
    
    % Handle special cases near ±T/(2*alpha)
    special_idx = abs(abs(t) - T/(2*alpha)) < 1e-10;
    p(special_idx) = (pi/4) * sinc(1/(2*alpha));
    
    % All other points
    idx = ~(t == 0 | special_idx);
    p(idx) = sinc(t(idx)/T) .* cos(pi*alpha*t(idx)/T) ./ (1 - (2*alpha*t(idx)/T).^2);
    
    % Handle any numerical issues
    p(isnan(p)) = 0;
    
    % Normalize
    p = p / max(abs(p));
end