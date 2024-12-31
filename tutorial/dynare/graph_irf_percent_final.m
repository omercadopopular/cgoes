
figure(1)
subplot(2,3,1)
plot(0:100,A(1:101,2)-A(1,2))
title('Tax Rate')
ylabel('rate')
%axis([0 100 0 0.15])

subplot(2,3,2)
plot(0:100,100*(A(1:101,3)/A(1,3)-1))
title('Output')
ylabel('Percent of initial SS')
%axis([0 100 -1.1 2])

subplot(2,3,3)
plot(0:100,100*(A(1:101,4)-A(1,4))/A(1,4))
title('Consumption')
ylabel('Percent of initial SS')
%axis([0 20 0 1.1])

subplot(2,3,4)
plot(0:100,100*(A(1:101,5)-A(1,5))/A(1,5))
title('Investment')
ylabel('Percent of initial SS')

subplot(2,3,5)
plot(0:100,100*(A(1:101,6)-A(1,6))/A(1,6))
title('Hours')
ylabel('Percent of initial SS')

subplot(2,3,6)
plot(0:100,100*(A(1:101,7)-A(1,7))/A(1,7))
title('Capital Stock')
ylabel('Percent of initial SS')



return

figure(1)
subplot(3,2,1)
plot(0:40,A(1:41,2))
%plot(0:20,A(1:21,2),'g--')
title('Output')
%xlabel('Quarters')
%ylabel('Units')
%legend('Path','Location','southeast')
%axis([0 40 2.89 2.97])
subplot(3,2,2)
plot(0:40,A(1:41,3))
title('Consumption')
subplot(3,2,3)
plot(0:40,A(1:41,4))
title('Investment')
subplot(3,2,4)
plot(0:40,A(1:41,5))
title('Labor')
subplot(3,2,5)
plot(0:40,A(1:41,6))
title('Capital')

%help plot