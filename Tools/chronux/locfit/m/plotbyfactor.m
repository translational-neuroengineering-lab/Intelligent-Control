function plotbyfactor(x,y,f)
%
% very simplistic version of plotbyfactor.
% no symbols, will crash if more than 8 levels.
%

z = unique(f);
cols = ['k','r','g','m','c','y','b','w'];

for (i = 1:length(z))
  u = find(f==z(i));
  plot(x(u),y(u),'.','color',cols(i));
  hold on;
end;
hold off;

return;
