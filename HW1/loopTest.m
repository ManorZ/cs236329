function loopTest(N)
for n=1:N
    if mod(n, 2) == 0 && mod(n, 3) == 0
        fprintf('%d is divisible by 2 AND 3\n', n);
    elseif mod(n, 2) == 0
        fprintf('%d is divisible by 2\n', n);
    elseif mod(n, 3) == 0
        fprintf('%d is divisible by 3\n', n);
    else
        fprintf('%d is NOT divisible by 2 or 3\n', n);
    end
end