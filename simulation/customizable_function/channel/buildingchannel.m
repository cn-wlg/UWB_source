clc
clear
close all

% cm_num = 1:Residential LOS
% cm_num = 2:Residential NLOS
% cm_num = 3:Office LOS
% cm_num = 4:Office NLOS
% cm_num = 5:Outdoor LOS
% cm_num = 6:Outdoor NLOS
% cm_num = 7:Industrial LOS
% cm_num = 8:Industrial NLOS

% cm_num = 4;
% UWBChannel = UWBchannelbulding(cm_num);
% ATKUWBChannel = UWBchannelbulding(cm_num);
% plot(abs(UWBChannel))
% save('H_channel_NLOS.mat','UWBChannel','ATKUWBChannel')

cm_num = 3;
num = 100000;
for i = 1:num
    UWBChannel = UWBchannelbulding(cm_num);
    % UWBChannelset{i} = createLOS(UWBChannel);
    UWBChannelset{i} = UWBChannel;
    ATKUWBChannel = UWBchannelbulding(cm_num);
    % ATKUWBChannelset{i} = createLOS(ATKUWBChannel);
    ATKUWBChannelset{i} = ATKUWBChannel;
end

save('UWBLOSChannelset_100000.mat','UWBChannelset','ATKUWBChannelset');

% cm_num = 2;
% for i = num+1:2*num
%     UWBChannel = UWBchannelbulding(cm_num);
%     UWBChannelset{i} = UWBChannel;
%     ATKUWBChannel = UWBchannelbulding(cm_num);
%     ATKUWBChannelset{i} = ATKUWBChannel;
% end

% ATKUWBChannel = UWBchannelbulding(cm_num);
% ATKUWBChannel2 = UWBchannelbulding(cm_num);


% save('UWBNLOSChannelset_new.mat','UWBChannelset','ATKUWBChannelset');

function out = createLOS(in)
len = length(in);

[~,maxidx] = max(in);
out = in(maxidx:end,1);
end