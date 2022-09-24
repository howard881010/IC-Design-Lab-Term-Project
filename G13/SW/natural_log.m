clc;clear all;close all;
k = 4; % Used for the repeated (3*k + 1) iteration steps
input = 123.5
x = input + 1;
y = input - 1;
z = 0;

for index = 0:28
    idx = index - 5;
    if idx > 0
        xtmp = bitsra(x, idx); % multiply by 2^(-idx)
        ytmp = bitsra(y, idx); % multiply by 2^(-idx)
        z_value = bitsra(1,idx);
        ztmp = atanh(z_value);
    else
        xtmp = x - bitsra(x, 2-idx);
        ytmp = y - bitsra(y, 2-idx);
        z_value = 1 - bitsra(1, 2-idx);
        ztmp = atanh(z_value);
    end
    if x*y >= 0
        x(:) = x - ytmp;
        y(:) = y - xtmp;
        z(:) = z + ztmp;
    else
        x(:) = x + ytmp;
        y(:) = y + xtmp;
        z(:) = z - ztmp;
    end
end % idx loop
 
 result = 2 * z
 golden = log(input)