active_ch = [2, 4, 6, 8, 9, 11, 13, 15];
passive_ch = [1, 3, 5, 7, 10, 12, 14, 16];
ARN = '038';
experiment_tag = 'Afterdischarge_Optimization';
date = '2015-12-28';
tank = 'MainDataTank';

for block_n = [20 21]
    
    block   = ['Block-' num2str(block_n)];
    data    = [];
    
    for c1 = 1:length(active_ch)
        d           = TDT2mat(tank, block, 'CHANNEL', active_ch(c1), 'STORE', 'Wave');
        data(c1,:)  = d.streams.Wave.data;         
    end
    
    s  = sprintf('C:\\Users\\TDT\\Dropbox\\stimulation data\\ARN 038 AD Optimization\\ARN%s_%s_%s.mat'...
                ,ARN, tank, block);
   
    save(s, 'data');
end