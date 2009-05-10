
dat = dlmread("output.csv",",");

size(dat)
figure(1),plot(dat)
figure(2),plot(dat(:,1), dat(:,2))

fs = 48000;
wavwrite(dat, fs, "output.wav")
