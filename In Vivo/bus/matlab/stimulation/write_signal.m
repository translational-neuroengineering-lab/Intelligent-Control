function write_signal( TD, channels, signal )

for c1 = 1:size(channels,2)
    TD.write(['stim_buff~' num2str(channels(c1))], signal);
    TD.write(['dur~' num2str(channels(c1))], numel(signal));
end

disp('allow time for channel to switch from open to closed')
pause(.05)

end

