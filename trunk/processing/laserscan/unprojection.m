function unprojection
% binarymillenium 2008
% gnu gpl v3

format compact;
% for the iqeye at 10 mm, fov was probably 97 degrees horiz and 74 degrees
% vertical

% camera position
campos = [0, 0, 0]';
% viewers position relative to display
%aleph = 97/180*pi;
% -1,-1 and 1,1 are the extents of the viewing surface
%ez = 1/tan(aleph/2)
%epos = [0, 0, ez]';

% from baseletters.jpg, width is 800, height is 640
bpixel = [301 61    0;
          290 509   0;
          598 379   0;
          623 24    0];
  
b = zeros(size(bpixel));
b(:,1) = -1 + 2*bpixel(:,1)/800;
b(:,2) =  1 - (2*bpixel(:,2)/800 + (800-640)/800);

% choose first depth arbitrarily
b(1,3) = 2;

ax = b(1,1);
ay = b(1,2);
bx = b(2,1);
by = b(2,2);
cx = b(3,1);
cy = b(3,2);

% the dot product of the two edges of the rectangle has to be zero
% meaning this equation has to determine ez
% (ax*az-bx*bz)*(cx*cz-bx*bz) + (ay*az-by*bz)*(cy-by)
val = ((ax-bx)*(cx-bx) + (ay-by)*(cy-by))
ez = sqrt(1/val)
epos = [0, 0, ez]';

%b(2:4,3) = solveDepth(b)
b(2:4,3) = solveDepth2(b,ez)


figure(1),subplot(2,1,1);
scatter(b(:,1), b(:,2));
hold on;
patch(b(:,1), b(:,2),'g');
hold off;
axis([-1, 1, -1, 1]);

%b = project(campos,epos);

% need to find the line perpendicular to the plane defined here
% use cross product
rota = zeros(size(b));
rota(1,:) = get3dCoords(b(1,:),epos)';
rota(2,:) = get3dCoords(b(2,:),epos)';
rota(3,:) = get3dCoords(b(3,:),epos)';
rota(4,:) = get3dCoords(b(4,:),epos)';


% rota1 = b(1,:);
% rota2 = b(2,:);
% rota3 = b(3,:);
% rota4 = b(4,:);

% this is going to ignore z-axis rotations
vec1 = rota(3,:)-rota(2,:);
vec1 = vec1/norm(vec1);
vec2 = rota(1,:)-rota(2,:);
vec2 = vec2/norm(vec2);
rotnorm = cross(vec1,vec2)
rotnrom = rotnorm/norm(rotnorm);
vec2norm = cross(rotnrom,vec1);

vec2
vec2norm
derivedrot1 = [vec1', vec2', rotnorm']


% this makes  the depth of all the found points the same,
% but the rectangle is skewed
% maybe some earlier assumptions are flawed?
% or more primary earlier assumption is to make the 
% adjacent rectangle edges orthogonal?
bcor = (derivedrot1'*rota')'

subplot(2,1,2);
scatter(bcor(:,1), bcor(:,2));
hold on;
patch(bcor(:,1), bcor(:,2),'g');
hold off;
axis([-3, 3, -3, 3]);




%% 
function C = solveDepth(v)
%az-dz= bz-cz
%az*ax - dz*dx = bz*bx - cz*cx
%az*ay - dz*dy = bz*by - cz*cy

% az    = bz    - cz    + dz
% az*ax = bz*bx - cz*cx + dz*dx
% az*ay = bz*by - cz*cy + dz*dy


%[az        [1  -1  1   [bz
% az*ax   =  bx -cx dx * cz
% az*zy]     by -cy dy]  dz]

% A = B*C
% Binv*A = Binv*B*C
% Binv*A = C

A = v(1,3)*[1 v(1,1) v(1,2)]';

B = [1      -1      1;
     v(2,1) -v(3,1) v(4,1);
     v(2,2) -v(3,2) v(4,2)];
 
C = inv(B)*A;


%% 
function z= solveDepth2(v,sz)

% the other solveDepth doesn't work very well, need to force
% contraint that the dot product of adjacent rect edges
% needs to be zero

% TBD make a the point at which everything else is centered, rather than b?
% v1 = (a'-b')
% v2 = (c'-b')
% v1.x = a.x*a.z/sz - b.x*b.z/sz  = (a.x*a.z - b.x*b.z)/sz
% v1.y = a.y*a.z/sz - b.y*b.z/sz  = (a.y*a.z - b.y*b.z)/sz
% v1.x*v2.x = (a.x*a.z - b.x*b.z)*(c.x*c.z - b.x*b.z)/sz^2
% ax' = ax * az   etc.
% dot(v1,v2) = 0
% (a.x*a.z - b.x*b.z)*(c.x*c.z - b.x*b.z)/sz^2 + 
% (a.y*a.z - b.y*b.z)*(c.y*c.z - b.y*b.z)/sz^2 + 
% (a.z - b.z)*(c.z - b.z) = 0

% 1/sz^2 * ((a.x*a.z - b.x*b.z)*(c.x*c.z - b.x*b.z)  + 
%           (a.y*a.z - b.y*b.z)*(c.y*c.z - b.y*b.z)) +
%           (a.z - b.z)*(c.z - b.z) = 0

% 1/sz^2 * ((a.x*a.z*c.x*c.z - b.x*b.z*c.x*c.z - b.x*b.z*a.x*a.z + b.x^2*b.z^2) +
%           (a.y*a.z*c.y*c.z - b.y*b.z*c.y*c.z - b.y*b.z*a.y*a.z + b.y^2*b.z^2)
%           (a.z*c.z - a.z*b.z - b.z*c.z + b.z*b.z) = 0

% 1/sz^2 *   (a.z*c.z*(a.x*c.x + a.y*c.y + 1)
%           - b.z*(b.x*(c.x*c.z + a.x*a.z) + b.y*(c.y*c.z + a.y*a.z) +a.z +c.z)
%             b.z^2 * (b.x^2 + b.y^2 + 1)  = 0

% 1/sz^2 *   (a.z*c.z*(a.x*c.x + a.y*c.y + 1)
%           - b.z*(a.z( b.y*a.y + b.x*a.x + 1 ) + c.z*(b.y*c.y + b.x*c.x 1))
%             b.z^2 * (b.x^2 + b.y^2 + 1)  = 0

ax = v(1,1);
ay = v(1,2);
bx = v(2,1);
by = v(2,2);
cx = v(3,1);
cy = v(3,2);

az = v(1,3);

cz = [-10:1:-az]';

% reduces to quadratic formula
c = 1/sz^2 * (az*cz*(ax*cx + ay*cy + 1)) 
b = -1/sz^2 * (az*( by*ay + bx*ax + 1 ) + cz*(by*cy + bx*cx + 1))
a = (bx^2 + by^2 + 1)
% how to solve for cz?

topqf = b.*b - 4*a*c
topqf2 = (-b + sqrt(topqf))

% % (az+cz)*(az+cz) > 4*(az*cz+val)
% % az^2 + cz^2 + 2*az*cz -4*az*cz +4*val > 0
% % cz^2 + cz*(-2*az) + 4*val = 0  for minimum cz
% a = 1;
% b = (-2*az);
% c = 4*val;
% 
% % czmin > az, so choose the first
% czminp = (-b + sqrt(b.*b - 4*a*c))/(2*a);
% czminn = (-b - sqrt(b.*b - 4*a*c))/(2*a);
% 
% cz = czminp;
% 
% c = az*cz + val;
% b = -(az+cz);
% a = 1;
% 
% 
bzp = (-b + sqrt(b.*b - 4*a*c))/(2*a)
bzn = (-b - sqrt(b.*b - 4*a*c))/(2*a)

% arbitrarily choose the smaller bz
bz = bzp;

%az-dz= bz-cz
dz = az - bz + cz;

z = [bz cz dz];

%%
function b = project(campos,epos)


camtheta = [pi*3/180,pi*30/180,pi*1/180]';

% triangle coords in 3d space
dist = 6.5;
a1 = [-1,1,dist]';
a2 =[-1,-1,dist]';
a3 = [1,-1,dist]';
a4 = [1, 1,dist]';




rotx = [1   0                   0; 
        0   cos(-camtheta(1))   sin(-camtheta(1)); 
        0  -sin(-camtheta(1))   cos(-camtheta(1)) ]; 
        
        
roty = [cos(-camtheta(2))   0  -sin(-camtheta(2)); 
        0                   1   0;
        sin(-camtheta(2))   0   cos(-camtheta(2)) ];
    
    
rotz = [cos(-camtheta(3))   sin(-camtheta(3))   0; 
       -sin(-camtheta(3))   cos(-camtheta(3))   0;
        0                   0                   1];

b =zeros(4,4);

rot = rotx*roty*rotz
b(1,:) = getScreenCoords(rot, a1, campos, epos);
b(2,:) = getScreenCoords(rot, a2, campos, epos);    
b(3,:) = getScreenCoords(rot, a3, campos, epos);   
b(4,:) = getScreenCoords(rot, a4, campos, epos); 

b
 
figure(1),
scatter(b(:,1), b(:,2));
hold on;
patch(b(:,1), b(:,2),'g');
hold off;
axis([-1, 1, -1, 1]);

%%
function b = getScreenCoords(rot, a, campos, epos)
    
d = [rot*(a-campos); 1];

homg = ...
[1 0 0         -epos(1);
 0 1 0         -epos(2);
 0 0 1          0;
 0 0 1/epos(3)  0];

f = homg*d;

b = f;
b(1) = f(1)/f(4);
b(2) = f(2)/f(4);
% f(3) turns out to be the distance from the screen, not from the viewer


%b = [0,0];
%b(1) = (d(1) - epos(1))*(epos(3)/d(3));
%b(2) = (d(2) - epos(2))*(epos(3)/d(3));

%%  convert b from pixel coordinates to -1 to 1 coordinates
function rota = get3dCoords(b, epos)

d = [0, 0, b(3)]';
d(1) = b(1)/(epos(3)/d(3)) + epos(1);
d(2) = b(2)/(epos(3)/d(3)) + epos(2);

rota = d;
