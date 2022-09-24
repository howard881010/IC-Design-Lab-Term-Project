clc;clear all;close all;
k = 4; % Used for the repeated (3*k + 1) iteration steps
n = 30;
input = 789456
value = input;
exp = 0;
v = input;
if (input >= 2)
    while (v >= 2)
        v = v / 2;
        exp = exp + 1;
    end
end
if (input < 0.5)
    while (v < 0.5)
        v = v * 2;
        exp = exp - 1;
    end
end
    

if mod(exp,2) == 0
    exp = exp / 2;
else 
    exp = (exp - 1) / 2;
    v = v * 2;
end
    
x = v + 0.25;
y = v - 0.25;

for idx = 1:n
    xtmp = bitsra(x, idx); % multiply by 2^(-idx)
    ytmp = bitsra(y, idx); % multiply by 2^(-idx)
    if y < 0
        x(:) = x + ytmp;
        y(:) = y + xtmp;
    else
        x(:) = x - ytmp;
        y(:) = y - xtmp;
    end
     if idx==k
         xtmp = bitsra(x, idx); % multiply by 2^(-idx)
         ytmp = bitsra(y, idx); % multiply by 2^(-idx)
         if y < 0
             x(:) = x + ytmp;
             y(:) = y + xtmp;
         else
             x(:) = x - ytmp;
             y(:) = y - xtmp;
         end
         k = 3*k + 1;
      end
 end % idx loop
 a = 1;
 
 for idx = 1:n
    xtmp = bitsra(1, 2*idx); % multiply by 2^(-idx)
    a = a * sqrt(1-xtmp);
 end
 format long
 b = 1/a;
 result = x / a * 2^exp
 golden = sqrt(value)
 
 