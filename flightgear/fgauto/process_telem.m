
clear;

f = csvread('telemetry.csv');
%fid = fopen("telemetry.csv");
%f = fscanf(fid,'%f,%f,%f',[3, 1000]);
f = f';


len =size(f,2)
t = [1:len]/10;

figure(1);
plot(f(1,:), f(2,:));
ylabel('long vs. lat');

figure(2),
plot(f(3,:));
ylabel('altitude');

r2d = 180/pi;
p = f(4,:)*r2d;
q = f(5,:)*r2d;
dq = f(10,:);
iq = f(11,:);
r = f(6,:)*r2d;

err_head = f(12,:);
derr_head = f(13,:);

elev = f(7,:);
rud = f(8,:);
ail = f(9,:);

figure(3),
plot(t,p, t,q,t,r);
legend('p','q','r');

figure(4),
factor = 100; % max(abs(q))/ max(abs(elev));
plot(t,q, t, elev*factor,t,dq*5, t, iq*50);
ylabel('radians/sec, or other units');
legend('q', 'elevator', 'dq','iq');

%figure(5),
%plot(t,rud*100, t,err_head, t, derr_head/10);
%legend('rudder', 'error heading', 'derror heading');
