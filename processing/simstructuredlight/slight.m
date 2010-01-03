
p1 = sum(double(imread('data/00003phase1.jpg')),3)/3;
p2 = sum(double(imread('data/00003phase2.jpg')),3)/3;
p3 = sum(double(imread('data/00003phase3.jpg')),3)/3;

pavg = (p1+p2+p3)/3;

figure(1);

colormap('gray')
image(p2)

figure(2);

p1_fft = fft((p1));

p1_fft = p1_fft(1:size(p1_fft,1)/4,:);
subplot(2,1,2),plot( angle(p1_fft(:,[1:40:end]) ) );
%image(255*angle(p1_fft)/pi);
colormap('gray');
%colormap('jet');
subplot(2,1,1),plot(abs(p1_fft(:,[1:40:end])));
%image(255*abs(p1_fft)/ max(max(abs(p1_fft) )));


% find the peak frequency

avgfft = (sum(abs(p1_fft')));
ofs = 20;
ofs_avgf = avgfft(ofs:end);
peak_f = ofs + find(ofs_avgf == max(ofs_avgf));
display(['peak freq at ' num2str(peak_f)]);

if (0)
figure(3);

flatp1 = double(reshape(p1,prod(size(p1)),1));
flatp2 = double(reshape(p2,prod(size(p2)),1));
flatp3 = double(reshape(p3,prod(size(p3)),1));
flatpa = double(reshape(pavg,prod(size(pavg)),1));
numbins = 128;
[n1,x1] = hist(flatp1,numbins);
[n2,x2] = hist(flatp2,numbins);
[n3,x3] = hist(flatp3,numbins);
[na,xa] = hist(flatpa,numbins);

%plot(xa,na-n3);
plot(xa,na,x1,n1,x2,n2,x3,n3);
end