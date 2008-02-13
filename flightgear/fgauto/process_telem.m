
clear;

f = csvread('telemetry.csv');
%fid = fopen("telemetry.csv");
%f = fscanf(fid,'%f,%f,%f',[3, 1000]);
f = f';


len =size(f,2)

l = round(len*0.9);

t = [1:l]/10;
r2d = 180/pi;

p = f(4,1:l)*r2d;
q = f(5,1:l)*r2d;
r = f(6,1:l)*r2d;

err_head = f(12,1:l);
derr_head = f(13,1:l);
ierr_head = f(14,1:l);

elev = f(7,1:l);
rud = f(8,1:l);
ail = f(9,1:l);

dq = f(10,1:l);
iq = f(11,1:l);

pitch  = f(15,1:l);
dpitch = f(16,1:l);
ipitch = f(17,1:l);

tpitch = f(18,1:l);
speed = f(19,1:l);

tdx = f(20,1:l);
tdy = f(21,1:l);

wind = f(22,1:l);
wind_dir = f(23,1:l);
press = f(24,1:l);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);
plot(tdx, tdy);
ylabel('tdx vs. tdy');

figure(2),
subplot(2,1,1),plot(t,f(3,1:l));
ylabel('altitude meters');
xlabel('time seconds');

subplot(2,1,2),plot(t,speed);
legend('speed');
ylabel('meters/second');

figure(3),
plot(t,p, t,q,t,r);
legend('p','q','r');

figure(4),
factor = 100; % max(abs(q))/ max(abs(elev));
subplot(2,1,1),plot(t,elev*factor, t, q,t,dq*500, t, iq*10);
ylabel('radians/sec, or other units');
legend('elevator','q', 'dq','iq');
subplot(2,1,2),plot(t, elev, t,pitch, t, tpitch, t, dpitch*50, t, ipitch/5);
legend('elev', 'gps derived pitch', 'tpitch', 'dpitch', 'ipitch');

figure(5),
plot(t,rud*100, t,err_head, t, derr_head*10, t, ierr_head/10);
ylabel('degrees');
legend('rudder', 'error heading', 'derror heading', 'ierr head');

figure(6),
subplot(3,1,1),plot(t,wind);
ylabel('wind knots');
subplot(3,1,2),plot(t,wind_dir);
ylabel('wind dir degrees');
subplot(3,1,3),plot(t,press);
ylabel('pressure inhg');



