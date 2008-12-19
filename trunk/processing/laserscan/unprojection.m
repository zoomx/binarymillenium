function unprojection
% binarymillenium 2008
% gnu gpl v3

format compact;
% for the iqeye at 10 mm, fov was probably 97 degrees horiz and 74 degrees
% vertical

% camera position
campos = [0, 0, 0]';
% viewers position relative to display
aleph = 97/180*pi;
% -1,-1 and 1,1 are the extents of the viewing surface
ez = 1/tan(aleph/2)
epos = [0, 0, ez]';

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

b(2:4,3) = solveDepth(b)


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

rota


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
