clc
clear
close all

fakeDRBGtemp = [];
numfakeSTS = 1000;
for i = 1:numfakeSTS
numfakeDBRG = 64;
upper96_bi = round(rand(1,96));
upper96_bi1 = upper96_bi(1:32);
upper96_bi2 = upper96_bi(33:64);
upper96_bi3 = upper96_bi(65:96);
upper96 = [dec2hex(bi2de(upper96_bi1),8),dec2hex(bi2de(upper96_bi2),8),dec2hex(bi2de(upper96_bi3),8)];

key_bi = round(rand(1,128));
key_bi1 = key_bi(1:32);
key_bi2 = key_bi(33:64);
key_bi3 = key_bi(65:96);
key_bi4 = key_bi(97:128);
key = [dec2hex(bi2de(key_bi1),8),dec2hex(bi2de(key_bi2),8),dec2hex(bi2de(key_bi3),8),dec2hex(bi2de(key_bi4),8)];

counter_bi = round(rand(1,32));
counter = dec2hex(bi2de(counter_bi),8);
fakeDRBGtemp = [];
for k = 1:numfakeDBRG
    Out = Cipher(key,[upper96,counter]);
    Out_bin = [de2bi(hex2dec(Out(1:8)),32),de2bi(hex2dec(Out(9:16)),32),de2bi(hex2dec(Out(17:24)),32),de2bi(hex2dec(Out(25:32)),32)];
    fakeDRBGtemp = [fakeDRBGtemp;Out_bin];
    counter = dec2hex(hex2dec(counter)+1,8);
end
fakeDRBG(:,:,i) = fakeDRBGtemp;
end

save('fakeDRBG(64_1000).mat','fakeDRBG')



legalDRBGtemp = [];
numfakeSTS = 1;
for i = 1:numfakeSTS
numfakeDBRG = 64;
upper96_bi = round(rand(1,96));
upper96_bi1 = upper96_bi(1:32);
upper96_bi2 = upper96_bi(33:64);
upper96_bi3 = upper96_bi(65:96);
upper96 = [dec2hex(bi2de(upper96_bi1),8),dec2hex(bi2de(upper96_bi2),8),dec2hex(bi2de(upper96_bi3),8)];

key_bi = round(rand(1,128));
key_bi1 = key_bi(1:32);
key_bi2 = key_bi(33:64);
key_bi3 = key_bi(65:96);
key_bi4 = key_bi(97:128);
key = [dec2hex(bi2de(key_bi1),8),dec2hex(bi2de(key_bi2),8),dec2hex(bi2de(key_bi3),8),dec2hex(bi2de(key_bi4),8)];

counter_bi = round(rand(1,32));
counter = dec2hex(bi2de(counter_bi),8);
legalDRBGtemp = [];
for k = 1:numfakeDBRG
    Out = Cipher(key,[upper96,counter]);
    Out_bin = [de2bi(hex2dec(Out(1:8)),32),de2bi(hex2dec(Out(9:16)),32),de2bi(hex2dec(Out(17:24)),32),de2bi(hex2dec(Out(25:32)),32)];
    legalDRBGtemp = [legalDRBGtemp;Out_bin];
    counter = dec2hex(hex2dec(counter)+1,8);
end
legalDRBG(:,:,i) = legalDRBGtemp;
end

save('legalDRBG.mat','legalDRBG')