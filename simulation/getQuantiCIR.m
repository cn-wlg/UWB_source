function [output] = getQuantiCIR(CIR,net,bits)
% GETQUANTICIR: 执行CIR映射功能，将输入的长为700*1的CIR数据映射为128bit的二进制序列
% 输入: CIR数据
%       训练好的自编码器网络
% 输出: 量化后的二进制比特序列
% 提取隐含层
layers = net.Layers;

% split layers
splitLayerIndex = 7;
Encodelayers = layers(1:splitLayerIndex);
Encodelayers = [Encodelayers;regressionLayer];
Decodelayers = layers(splitLayerIndex+1:end);
Decodelayers = [sequenceInputLayer(32);Decodelayers];
Encodenet = assembleNetwork(Encodelayers);
Decodenet = assembleNetwork(Decodelayers);

% 得到自编码器结果
encodeout = predict(Encodenet,CIR);

% 量化输出
[encodeout_quan,~] = Quantization(encodeout,bits);

tmp = de2bi(encodeout_quan,bits).';
output = tmp(:);
end

function [out,quan_table] = Quantization(in,bits)
q = 2^bits;
quan_table = [0:1/(q-1):1];
for i = 1:length(in)
    temp = abs(quan_table - in(i));
    [~,minidx] = min(temp);
    out(i,1) = minidx-1;
end
end
