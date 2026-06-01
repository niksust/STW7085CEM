% ========================================================
% PART 2: Genetic Algorithm Optimization of FLC
% Optimizes membership function parameters (54 genes)
% No toolbox required — pure MATLAB GA from scratch
% ========================================================

clear; clc; close all;

%% Helper function
function y = trimf_val(x, params)
    a=params(1); b=params(2); c=params(3);
    y=zeros(size(x));
    if a~=b, idx=(x>=a)&(x<=b); y(idx)=(x(idx)-a)/(b-a); end
    if b~=c, idx=(x>b)&(x<=c);  y(idx)=(c-x(idx))/(c-b); end
    y(x==b)=1;
end

%% Parameterized FLC function
function [h_out, d_out] = flc_ga(T, L, A, p)
    out = 0:1:100;
    tc=trimf_val(T,p(1:3)); tco=trimf_val(T,p(4:6)); th=trimf_val(T,p(7:9));
    ld=trimf_val(L,p(10:12)); lm=trimf_val(L,p(13:15)); lb=trimf_val(L,p(16:18));
    al=trimf_val(A,p(19:21)); am=trimf_val(A,p(22:24)); ah=trimf_val(A,p(25:27));
    r1=tc;r2=th;r3=tco;r4=min(tc,ah);r5=min(tc,al);r6=min(th,ah);r7=min(tco,al);
    r8=ld;r9=lb;r10=lm;r11=min(ld,ah);r12=min(ld,al);r13=min(lm,al);r14=min(lb,ah);
    hoff=trimf_val(out,p(28:30));hlow=trimf_val(out,p(31:33));
    hmed=trimf_val(out,p(34:36));hhi=trimf_val(out,p(37:39));hful=trimf_val(out,p(40:42));
    doff=trimf_val(out,p(43:45));dlow=trimf_val(out,p(46:48));
    dmed=trimf_val(out,p(49:51));dhi=trimf_val(out,p(52:54));
    ha=max([min(r2,hoff);min(r6,hoff);min(r7,hlow);min(r3,hmed);min(r4,hhi);min(r1,hful);min(r5,hful)]);
    da=max([min(r9,doff);min(r14,doff);min(r12,dlow);min(r13,dlow);min(r10,dmed);min(r8,dhi);min(r11,dhi)]);
    if sum(ha)==0,h_out=50; else,h_out=sum(out.*ha)/sum(ha); end
    if sum(da)==0,d_out=50; else,d_out=sum(out.*da)/sum(da); end
end

%% Fitness function
function mse = fitness(params)
    data=[5 10 1 88 65; 35 90 9 5 5; 22 55 5 50 52;
          10 20 2 80 30; 30 80 8 8 10; 15 30 8 72 75; 25 60 3 38 38];
    try
        mse=0;
        for i=1:size(data,1)
            [h,d]=flc_ga(data(i,1),data(i,2),data(i,3),params);
            mse=mse+(h-data(i,4))^2+(d-data(i,5))^2;
        end
        mse=mse/size(data,1);
    catch
        mse=1e8;
    end
end

%% GA from scratch
function [bestX,bestVal,history] = runGA(fitFunc,nVars,lb,ub,popSize,nGen)
    pop = lb + (ub-lb).*rand(popSize,nVars);
    bestVal=inf; bestX=pop(1,:); history=zeros(nGen,1);
    for gen=1:nGen
        fit=zeros(popSize,1);
        for i=1:popSize, fit(i)=fitFunc(pop(i,:)); end
        [gBest,idx]=min(fit);
        if gBest<bestVal, bestVal=gBest; bestX=pop(idx,:); end
        history(gen)=bestVal;
        % Tournament selection
        newPop=zeros(popSize,nVars);
        for i=1:popSize
            c=randperm(popSize,3); [~,w]=min(fit(c)); newPop(i,:)=pop(c(w),:);
        end
        % Crossover
        for i=1:2:popSize-1
            if rand<0.8
                pt=randi(nVars-1);
                c1=[newPop(i,1:pt),newPop(i+1,pt+1:end)];
                c2=[newPop(i+1,1:pt),newPop(i,pt+1:end)];
                newPop(i,:)=c1; newPop(i+1,:)=c2;
            end
        end
        % Mutation
        mask=rand(popSize,nVars)<0.15;
        newPop=newPop+mask.*randn(popSize,nVars).*(ub-lb)*0.05;
        newPop=max(newPop,lb); newPop=min(newPop,ub);
        newPop(1,:)=bestX; % elitism
        pop=newPop;
        if mod(gen,10)==0
            fprintf('  Generation %3d/%d — Best MSE: %.4f\n',gen,nGen,bestVal);
        end
    end
end

%% Run GA
nVars=54;
lb=[0 0 5, 5 15 20, 22 30 35, 0 0 15, 20 35 55, 55 80 100,...
    0 0 1, 2 4 6, 5 8 10, 0 0 10, 10 25 40, 40 52 65, 60 75 85, 82 95 100,...
    0 0 8, 10 28 45, 45 58 72, 65 78 100];
ub=[0 5 18, 10 25 32, 25 40 40, 0 15 40, 30 55 72, 62 100 100,...
    0 1 4, 3 6 8, 7 10 10, 0 8 25, 15 38 52, 50 62 78, 65 88 95, 88 100 100,...
    0 8 22, 15 38 55, 52 68 82, 72 88 100];

fprintf('==========================================\n');
fprintf('  Genetic Algorithm — FLC Optimization\n');
fprintf('  Chromosome length : %d genes\n',nVars);
fprintf('  Population size   : 60\n');
fprintf('  Generations       : 80\n');
fprintf('  Crossover rate    : 0.80\n');
fprintf('  Mutation rate     : 0.15 per gene\n');
fprintf('  Selection         : Tournament (size 3)\n');
fprintf('  Elitism           : 1 elite individual\n');
fprintf('==========================================\n\n');

rng(42);
[bestP, bestMSE, history] = runGA(@fitness, nVars, lb, ub, 60, 80);

fprintf('\n==========================================\n');
fprintf('  RESULT: Best MSE = %.4f\n', bestMSE);
fprintf('==========================================\n\n');

%% FIGURE 8: GA Convergence Plot
figure('Name','Figure 8 - GA Convergence','Position',[100 100 750 450]);
plot(1:80, history, 'b-', 'LineWidth', 2.5);
hold on;
[mv,mi] = min(history);
plot(mi, mv, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(mi+1, mv, sprintf('  Best = %.2f\n  Gen %d', mv, mi),...
    'FontSize', 10, 'Color', 'r', 'FontWeight', 'bold');
xlabel('Generation', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Best MSE (Fitness)', 'FontSize', 12, 'FontWeight', 'bold');
title('Figure 8: GA Convergence — FLC Membership Function Optimization',...
    'FontSize', 12, 'FontWeight', 'bold');
grid on; box on;
legend(sprintf('Best fitness per generation\nFinal MSE = %.4f', bestMSE), 'Location', 'northeast');
set(gca, 'FontSize', 11);

%% FIGURE 9: Before vs After Optimization
test_inputs = [22 55 5; 5 10 1; 35 90 9; 10 20 2; 30 80 8];
labels = {'T=22 L=55 A=5','T=5 L=10 A=1','T=35 L=90 A=9','T=10 L=20 A=2','T=30 L=80 A=8'};
h_before=zeros(5,1); d_before=zeros(5,1);
h_after =zeros(5,1); d_after =zeros(5,1);

defaultP=[0 0 18,12 22 30,25 40 40,...
          0 0 35,25 50 75,65 100 100,...
          0 0 4, 3 5 7,  6 10 10,...
          0 0 25,15 35 55,45 60 75,65 82 95,85 100 100,...
          0 0 20,15 35 55,50 65 80,70 85 100];

fprintf('%-18s | H_before | D_before | H_after | D_after\n','Scenario');
fprintf('%s\n',repmat('-',1,62));
for i=1:5
    [h_before(i),d_before(i)] = flc_ga(test_inputs(i,1),test_inputs(i,2),test_inputs(i,3),defaultP);
    [h_after(i), d_after(i)]  = flc_ga(test_inputs(i,1),test_inputs(i,2),test_inputs(i,3),bestP);
    fprintf('%-18s | %8.1f | %8.1f | %7.1f | %7.1f\n',...
        labels{i},h_before(i),d_before(i),h_after(i),d_after(i));
end

figure('Name','Figure 9 - Before vs After GA','Position',[100 100 950 420]);
x=1:5;
subplot(1,2,1);
bar(x,[h_before,h_after],0.65);
set(gca,'XTickLabel',labels,'XTick',1:5,'FontSize',9); xtickangle(15);
ylabel('Heater Output (%)','FontWeight','bold');
title('Heater: Before vs After GA Optimization','FontWeight','bold');
legend('Before','After','Location','northeast'); ylim([0 115]); grid on;

subplot(1,2,2);
bar(x,[d_before,d_after],0.65);
set(gca,'XTickLabel',labels,'XTick',1:5,'FontSize',9); xtickangle(15);
ylabel('Dimmer Output (%)','FontWeight','bold');
title('Dimmer: Before vs After GA Optimization','FontWeight','bold');
legend('Before','After','Location','northeast'); ylim([0 115]); grid on;

sgtitle('Figure 9: FLC Output Before vs After Genetic Algorithm Optimization',...
    'FontSize',12,'FontWeight','bold');