function test

    tryfunction(anotherfunction);
    
end

function tryfunction(input)
    disp(input);
end

function out = anotherfunction
    out = 'test';
end

function [out1, out2] = tryAnother(input, input2)
    out1 = input;
    out2 = input * out1;
    out2 = out2 + input2;
end