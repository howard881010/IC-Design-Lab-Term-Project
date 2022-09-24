clc;clear all;close all;
input = 0
x = 0.607253;
y = 0.607253;
z = input - 45;

for idx = 1:29
    xtmp = bitsra(x, idx); % multiply by 2^(-idx)
    ytmp = bitsra(y, idx); % multiply by 2^(-idx)
    z_value = bitsra(1,idx);
    ztmp = atan(z_value) * 180 / pi;
    if z >= 0
        x(:) = x - ytmp;
        y(:) = y + xtmp;
        z(:) = z - ztmp;
    else
        x(:) = x + ytmp;
        y(:) = y - xtmp;
        z(:) = z + ztmp;
    end
end % idx loop

simulated_cos = x
aa = input*pi/180;
golden_cos = cos(aa)
simulated_sin = y
golden_sin = sin(aa)
