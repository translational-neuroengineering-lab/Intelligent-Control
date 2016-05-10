%% input signal
foi = 7.5;  % inject signal @ this frequency
Nch = 100;
tt = 1:(1000*T);
data = repmat(sin(foi*2*pi/1000*tt),Nch,1)';
data(:,51:90)= -1*data(:,51:90);               % make channels 51-90 antiphase
data(:,91:100) = 0;                            % channels 91-100 will be pure noise
data = data +.5* randn(size(data));            % add Gaussian noise

%% tapering parameters
W = 2; T = 2; p = 1; K = round(2*W*T-1); 

params.tapers = [W T p];   % W, T, p ... 2*10 - 1 = 19 tapers
params.Fs = 1000;
params.pad = 2;
params.fpass = [0 20];
params.err = [];% [2 .05];
params.trialave = false;

% sph = randn(size(sph));
%%  old chronux -- doesn't work
[sv,sp,fm] = spsvd(data,params);
df = diff(params.fpass)/size(sv,1);
f = params.fpass(1):df:params.fpass(end); f = f(1:end-1);

%%  modified function -- does work!
% [sv,sp,fm,f] = spsvd_yl(data,params);

% sv ... [f] x [modes] ... singular values
% sp ... [channels] x [f] x [modes] ... spatial modes
% fm ... [tapers] x [f] x [modes] ... frequency modes
%%
figure(1); clf;
nr = 2; nc = 3;

subplot(nr,nc,1);   % plot the input signal
imagesc(data');
title(sprintf('%.3g Hz signal + noise',foi));
xlabel('time (ms)'); ylabel('channels');
%% plot the eigenvalues for each frequency

subplot(nr,nc,2);
plot_matrix(sv',1:K,f);
xlabel('modes');
ylabel('freq (Hz)');
title('singular values');

%% compute and plot the global coherence

C = sv(:,1).^2./sum(sv.^2,2);  % lambda1/sum(lambda) for each freq

subplot(nr,nc,3);
plot(f,C,'k-','linewidth',2);
title('global coherence');
xlabel('freq (Hz)');

%% get the singular values and eigenvectors at frequency of interest
[~,fk] = min(abs(f-foi));

sv_f = sv(fk,:);
sp_f = squeeze(sp(:,fk,:));    % channels x modes
fm_f = squeeze(fm(:,fk,:));    % tapers x modes

%% plot the singular values @ FOI

subplot(nr,nc,4);
plot(1:K,sv_f,'ko-','markerfacecolor','k','linewidth',2);
set(gca,'xlim',[1 K]);
title(['singular values @ ' num2str(foi) ' Hz']);
xlabel('modes');

%% get the 1st spatial mode at FOI
sp_f1 = sp_f(:,1);

subplot(nr,nc,5);
plot(1:Nch,abs(sp_f1),'k-','linewidth',2);
xlabel('channels');
title(['1st spatial mode: magnitude']);

subplot(nr,nc,6);
plot(1:Nch,angle(sp_f1),'k-','linewidth',2);
xlabel('channels');
title('1st spatial mode: phase');

% %%
% figure(gcf);clf;
% nr = 3; nc = 2;
% subplot(nr,nc,1);
% plot_matrix(sv',1:size(sv,2),f,'n');
% xlabel('modes'); ylabel('freq');
% title('singular values');
% 
% subplot(nr,nc,2);
% C = sv(:,1).^2./sum(sv.^2,2);
% plot(f,C);
% xlabel('freq'); ylabel('coherence');
