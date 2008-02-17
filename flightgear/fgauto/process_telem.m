
clear;

f = csvread('telemetry.csv');
%fid = fopen("telemetry.csv");
%f = fscanf(fid,'%f,%f,%f',[3, 1000]);
f = f';


len =size(f,2)

l = round(len*0.9);

t = [10:l]/20;
r2d = 180/pi;

long = f(1,10:l);
lat = f(2,10:l);
alt = f(3,10:l);

p = f(4,10:l)*r2d;
q = f(5,10:l)*r2d;
r = f(6,10:l)*r2d;

err_head = f(12,10:l);
derr_head = f(13,10:l);
ierr_head = f(14,10:l);

% control surfaces
elev = f(7,10:l);
rud = f(8,10:l);
ail = f(9,10:l);

dq = f(10,10:l);
iq = f(11,10:l);

epitch  = f(15,10:l);
dpitch = f(16,10:l);
ipitch = f(17,10:l);

tpitch = f(18,10:l);
speed = f(19,10:l);

tdx = f(20,10:l);
tdy = f(21,10:l);

wind = f(22,10:l);
wind_dir = f(23,10:l);
press = f(24,10:l);

dr = f(25,10:l);
ir = f(26,10:l);

pitch = f(27,10:l);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
%instead of lat(end) should use coords of actual target, and make an x where the target is
y = (lat-lat(end))*6e6;
subplot(2,1,1),plot(t,y);
ylabel('dist meters');
xlabel('time seconds');
y2 = (long-long(end))*6e6.*cos(lat);
subplot(2,1,2),plot(t, y2);
ylabel('dist meters');
xlabel('time seconds');

figure(10);
subplot(2,1,1),plot(y,y2,'b');
xlabel('distance meters');
ylabel('distance meters');
subplot(2,1,2),plot(sqrt(y.*y+y2.*y2),alt,'b');
xlabel('distance');
ylabel('altitude');

figure(2),
subplot(2,1,1),plot(t,alt);
ylabel('altitude meters');
xlabel('time seconds');

subplot(2,1,2),plot(t,speed);
legend('speed');
ylabel('meters/second');

figure(3),
subplot(2,1,1),plot(t,p, t,q,t,r);
legend('p','q','r');
ylabel('radians/second');
subplot(2,1,2),plot(t,rud, t,elev,t,ail);
legend('rudder','elevator','aileron');

figure(4),
factor = 100; % max(abs(q))/ max(abs(elev));
subplot(2,1,1),plot(t,elev*factor, t, q,t,dq*500, t, iq*10);
ylabel('radians/sec, or other units');
legend('elevator','q', 'dq','iq');
subplot(2,1,2),plot(t, elev, t,pitch, t, tpitch, t, dpitch*50, t, ipitch/5,t,epitch);
legend('elev', 'gps derived pitch', 'tpitch', 'dpitch', 'ipitch', 'error pitch');

figure(5),
plot(t,rud, t,err_head, t, derr_head*10, t, ierr_head/10);
ylabel('degrees');
legend('rudder', 'error heading', 'derror heading', 'ierr head');

if (0)
figure(6),
subplot(3,1,1),plot(t,wind);
ylabel('wind knots');
subplot(3,1,2),plot(t,wind_dir);
ylabel('wind dir degrees');
subplot(3,1,3),plot(t,press);
ylabel('pressure inhg');
end;

figure(7);
plot(t, r, t,dr,t,ir);
legend('r','dr','ir');


