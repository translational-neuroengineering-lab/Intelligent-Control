function open_channels(TD, channels)

disp('opening channels')

for c1 = 1:size(channels,2);
    TD.write(['stim_buff~' num2str(channels(c1))], 10000*ones(1,10));
    TD.write(['dur~' num2str(channels(c1))], 10);
end

end

