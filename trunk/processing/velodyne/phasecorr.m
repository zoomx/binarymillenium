function phasecorr
%function [old_polar,new_polar] = phasecorr
%
format compact

stored_image = zeros(800,800); %1500);

%filename = strcat('temp/frames/hgt/flat_prepross_height10',int2str(154),'.png');	
%filename = 'temp/frames/hgt/flat_prepross_height_10154.png';	
filename = 'temp/frames/hgt/flat_prepross_height_10120.png';	
old_raw = imread(filename);
old_image = sum(double(old_raw),3)/3/255;

[xl,yl] = size(old_image);

totx = 50;
toty = 50;

stored_image(totx:totx+xl-1,toty:toty+yl-1) = stored_image(totx:totx+xl-1,toty:toty+yl-1) + old_image;

totrot = 0;

for i = [122:2:126]  %[155:306]

zs = '';
if (i < 10)  zs = '00'; 
elseif (i < 100) zs = '0'; end;

filename = strcat('temp/frames/hgt/flat_prepross_height_10',zs,int2str(i),'.png');	
newraw = imread(filename);

new_image = sum(double(newraw),3)/3/255;

[sx,sy,rot] = some(old_image, new_image);
old_image = new_image;

if (sx > xl/2) sx = sx-xl; end;
if (sy > yl/2) sy = sy-yl; end;

% not sure why, but also get 1 back when it should be zero
totx = totx + sx-1;
% don't want to subtract 1 here
toty = round(toty + sy -1);

totrot = totrot + rot; 

new_image_rot = imrotate(new_image,-totrot,'nearest','crop' );

sis = stored_image(totx:totx+xl-1,toty:toty+yl-1);
stored_image(totx:totx+xl-1,toty:toty+yl-1) = (sis >= new_image_rot).*sis + (sis< new_image_rot).*new_image_rot;

end


colormap(gray(256));
%clipped_image = clip(stored_image/(0.5*max(max(stored_image))) * 255,255) ;
clipped_image = clip(stored_image*255,255) ;
image( clipped_image );

%%

function [sx, sy, rot] = some(old_image, new_image)

	[xl,yl] = size(new_image);

	%% Make polar representation of images
	old_polar = zeros(xl/2-1,720);
	new_polar = old_polar;

	for r = [1:size(old_polar,1)]
	for theta = [1:size(old_polar,2)]
	[x,y] = pol2cart(theta/size(old_polar,2)*2*pi,r);
	old_polar(r,theta) = old_image(round(x)+xl/2,round(y)+yl/2); %interp2(a, x+xl/2,y+yl/2);
	new_polar(r,theta) = new_image(round(x)+xl/2,round(y)+yl/2); %interp2(b, x+xl/2,y+yl/2);
	end
	end

	% ignore ground return points 
	old_polar = (old_polar > 0.5).* old_polar;
	new_polar = (new_polar > 0.5).* new_polar;
	[sxp,syp] = cp(old_polar,new_polar,2);

	rot = (syp-1)/size(old_polar,2)*360;

	new_image_rot = imrotate(new_image,-rot,'nearest','crop' );

	new_image = (new_image > 0.5).* new_image;
	old_image = (old_image > 0.5).* old_image;
	[sx,sy] = cp(old_image,new_image_rot,1);

	%colormap(gray(256));
	%image( (old_polar+new_polar)*255);

	outputstr = strcat(num2str(sx),' ',num2str(sy),', ',num2str(sxp),' ', num2str(syp), ', rot= ', num2str(rot) )
%%


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

