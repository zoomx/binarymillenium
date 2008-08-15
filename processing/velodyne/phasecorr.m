function phasecorr
%function [nicp,nicppolar,apolar,bpolar] = phasecorr
%
format compact

stored_image = zeros(600,1500);

%filename = strcat('temp/frames/hgt/flat_prepross_height10',int2str(154),'.png');	
filename = 'temp/frames/hgt/flat_prepross_height_10154.png';	
old_raw = imread(filename);
old_image = sum(double(old_raw),3)/3/255;

[xl,yl] = size(old_image);

totx = 50;
toty = 200;

for i = [155:306]
	filename = strcat('temp/frames/hgt/flat_prepross_height_10',int2str(i),'.png');	
    newraw = imread(filename);
    
	new_image = sum(double(newraw),3)/3/255;

	[sx,sy] = some(old_image, new_image);
	old_image = new_image;

	% not sure why, but also get 1 back when it should be zero
	totx = totx + sx-1;
	% don't want to subtract 1 here
	toty = round(toty + sy);

	stored_image(totx:totx+xl-1,toty:toty+yl-1) = stored_image(totx:totx+xl-1,toty:toty+yl-1) + new_image;

end


colormap(gray(256));
image(stored_image/max(max(stored_image)) * 255 );

%%

function [sx, sy] = some(old_image, new_image)

    [xl,yl] = size(new_image);

%% Make polar representation of images
if (0) 
apolar = zeros(xl/2-1,yl/2-1);
bpolar = apolar;

for r = [1:size(apolar,1)]
for theta = [1:size(apolar,2)]
   [x,y] = pol2cart(theta/size(apolar,2)*2*pi,r);
   apolar(r,theta) = a(round(x)+xl/2,round(y)+yl/2); %interp2(a, x+xl/2,y+yl/2);
   bpolar(r,theta) = b(round(x)+xl/2,round(y)+yl/2); %interp2(b, x+xl/2,y+yl/2);
end
end

[nicppolar,sxp,syp] = cp(apolar,bpolar,2);

sx
sy
sxp
syp_deg = syp/size(apolar,2)*360
end

[sx,sy] = cp(old_image,new_image,1);

function [sx,sy] = cp(a,b,figind)
%

[xl,yl] = size(a);

%hamming window
wn1 = 0.53836 -0.46164*(cos(2*pi*[0:xl-1]/xl));
wn2 = 0.53836 -0.46164*(cos(2*pi*[0:yl-1]/yl));
wn = wn1' * wn2;

%wn = ones(xl,yl);

af = fft2(a);% .* wn);
bf = fft2(b);% .* wn);

% cross power
cp = af.*conj(bf) ./ abs(af.*conj(bf));

icp = (ifft2(cp));

mmax = max(max(icp));
[sx,sy,v] = find(mmax == icp);

