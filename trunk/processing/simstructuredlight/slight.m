function angles=slight;
% binarymillenium Jan 2010
% GNU GPL v3.0

p1 = rot90(double( rgb2gray(imread('data/00003phase1.jpg'))));
p2 = rot90(double( rgb2gray(imread('data/00003phase2.jpg'))));
p3 = rot90(double( rgb2gray(imread('data/00003phase3.jpg'))));

% p1 = double( rgb2gray(imread('data/i1.png')));
% p2 = double( rgb2gray(imread('data/i2.png')));
% p3 = double( rgb2gray(imread('data/i3.png')));

p = zeros(size(p1,1),size(p1,2),3);

p(:,:,1) = p1;
p(:,:,2) = p2;
p(:,:,3) = p3;

pavg = sum(p,3)/3;

figure(1);

colormap('gray')
image(pavg/4);

figure(2);

angles = get_angle_full(p); %p(1:1,1:end/8,:));

x = [1:size(p1,2)/8];
p1sub = p1(1:1,1:end/8);
p2sub = p2(1:1,1:end/8);
p3sub = p3(1:1,1:end/8);

subplot(2,1,1), plot(x,p1sub, x,p2sub, x,p3sub);
subplot(2,1,2), plot(x,angles(1:1,1:end/8));
figure(3),
%subplot(1,2,1), image(p1/4);
%subplot(1,2,2),
image(255/4*angles/max(max(angles)));
colormap('gray');

%%
if (0)
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

%%
% p is a width * height * number of phases matrix
function angles = get_angle_full(p)

[h,w,phasenum] = size(p);

angles = zeros(h,w) -0.5;

for y=[1:h]
    for x = [1:w]
        angles(y,x) = get_angle(p(y,x,:));
    end
end

%%
% p is a vector of length number of phases
% angle is normalized 0.0 to 1.0
function angle = get_angle(ps)

% there will be 2*phasenum brackets in which to place the angles
phasenum = length(ps);

[ps_sorted,i] = sort(ps);

frt = ps_sorted(end);
frt_i = i(end);

sec = ps_sorted(end-1);
sec_i = i(end-1);

trd = ps_sorted(end-2);
trd_i = i(end-2);

angle_min = ((frt_i-1)- 0.5)/phasenum;

if ((frt-trd) > 0)
    angle_offset = (sec-trd)/(frt-trd)*0.5/phasenum;

    if (mod(sec_i-trd_i,phasenum) == 1)
        angle = angle_min - angle_offset; %angle_min + 0.5/phasenum - angle_offset
    else
        angle = angle_min + angle_offset; %angle_min; % + angle_offset;
    end

   %angle =angle_min;
   angle = mod(angle,1);
else  
   angle = -2;   
end

% for i = [1:phasenum]
%    testval = ps(i);
%    restvals = [ps(1:i-1),ps(:i+1:end)];
%    
%    if testval > max(restvals) 
%       % now we know we are in a section of angle ((i-1) +/- 0.5)/phasenum 
%    end
% end
