% ========================================================
% PART 3: CEC2005 Benchmark — GA vs PSO
% F1: Shifted Sphere | F6: Shifted Rosenbrock
% D=2 and D=10, 15 runs each — no toolbox required
% ========================================================

clear; clc; close all;

%% Benchmark functions
function y = f1(x), y = sum(x.^2) - 450; end
function y = f6(x)
    z=x+1; y=sum(100*(z(2:end)-z(1:end-1).^2).^2+(z(1:end-1)-1).^2)+390;
end

%% GA
function [bX,bV,hist] = myGA(f,D,lb,ub,pop,nGen)
    P=lb+(ub-lb).*rand(pop,D); bV=inf; bX=P(1,:); hist=zeros(nGen,1);
    for g=1:nGen
        fit=arrayfun(@(i)f(P(i,:)),1:pop)';
        [gB,id]=min(fit);
        if gB<bV,bV=gB;bX=P(id,:);end
        hist(g)=bV;
        nP=zeros(pop,D);
        for i=1:pop,c=randperm(pop,3);[~,w]=min(fit(c));nP(i,:)=P(c(w),:);end
        for i=1:2:pop-1
            if rand<0.8,pt=randi(D-1);
                t=nP(i,pt+1:end);nP(i,pt+1:end)=nP(i+1,pt+1:end);nP(i+1,pt+1:end)=t;
            end
        end
        nP=nP+((rand(pop,D)<0.15).*randn(pop,D).*(ub-lb)*0.05);
        nP=max(min(nP,ub),lb); nP(1,:)=bX; P=nP;
    end
end

%% PSO
function [bX,bV,hist] = myPSO(f,D,lb,ub,sw,nIter)
    pos=lb+(ub-lb).*rand(sw,D); vel=zeros(sw,D);
    pb=pos; pbV=arrayfun(@(i)f(pos(i,:)),1:sw)';
    [bV,gi]=min(pbV); bX=pb(gi,:); hist=zeros(nIter,1);
    for it=1:nIter
        vel=0.7*vel+1.5*rand(sw,D).*(pb-pos)+1.5*rand(sw,D).*(bX-pos);
        pos=max(min(pos+vel,ub),lb);
        vals=arrayfun(@(i)f(pos(i,:)),1:sw)';
        better=vals<pbV; pb(better,:)=pos(better,:); pbV(better)=vals(better);
        if min(vals)<bV,[bV,gi]=min(pbV);bX=pb(gi,:);end
        hist(it)=bV;
    end
end

%% Run experiments
nRuns=15; dims=[2,10];
funcs={@f1,@f6}; fnames={'F1-Sphere','F6-Rosenbrock'};

fprintf('================================================\n');
fprintf('   CEC2005 Benchmark: GA vs PSO Comparison\n');
fprintf('   Functions  : F1 Sphere, F6 Rosenbrock\n');
fprintf('   Dimensions : D=2, D=10\n');
fprintf('   Runs       : 15 per experiment\n');
fprintf('   GA params  : pop=50, gen=500\n');
fprintf('   PSO params : swarm=50, iter=500, w=0.7, c1=c2=1.5\n');
fprintf('================================================\n\n');

results=struct();
for fi=1:2
  for di=1:2
    D=dims(di); lb=-100*ones(1,D); ub=100*ones(1,D);
    ga_r=zeros(nRuns,1); pso_r=zeros(nRuns,1);
    fprintf('--- %s | D=%d ---\n',fnames{fi},D);
    for r=1:nRuns
        rng(r);
        [~,ga_r(r),~] =myGA( funcs{fi},D,lb,ub,50,500);
        [~,pso_r(r),~]=myPSO(funcs{fi},D,lb,ub,50,500);
        fprintf('  Run %2d: GA=%12.4f   PSO=%12.4f\n',r,ga_r(r),pso_r(r));
    end
    fprintf('\n  Algo | Mean         | Std          | Best         | Worst\n');
    fprintf('  %s\n',repmat('-',1,65));
    fprintf('  GA   | %12.4f | %12.4f | %12.4f | %12.4f\n',...
        mean(ga_r),std(ga_r),min(ga_r),max(ga_r));
    fprintf('  PSO  | %12.4f | %12.4f | %12.4f | %12.4f\n\n',...
        mean(pso_r),std(pso_r),min(pso_r),max(pso_r));
    key=sprintf('%s_D%d',strrep(fnames{fi},'-','_'),D);
    results.(key).ga=ga_r; results.(key).pso=pso_r;
  end
end

%% FIGURE 10: Convergence plots (5 sample runs each)
figure('Name','Figure 10 - CEC2005 Convergence','Position',[50 50 1300 650]);
cols=lines(5); plotIdx=1;
for fi=1:2
  for di=1:2
    D=dims(di); lb=-100*ones(1,D); ub=100*ones(1,D);

    subplot(2,4,plotIdx);
    hold on;
    for r=1:5
        rng(r); [~,~,h]=myGA(funcs{fi},D,lb,ub,50,200);
        plot(h,'Color',cols(r,:),'LineWidth',1.3);
    end
    title(sprintf('GA: %s D=%d',fnames{fi},D),'FontSize',9,'FontWeight','bold');
    xlabel('Generation'); ylabel('Best Fitness'); grid on; box on;
    plotIdx=plotIdx+1;

    subplot(2,4,plotIdx);
    hold on;
    for r=1:5
        rng(r); [~,~,h]=myPSO(funcs{fi},D,lb,ub,50,200);
        plot(h,'Color',cols(r,:),'LineWidth',1.3);
    end
    title(sprintf('PSO: %s D=%d',fnames{fi},D),'FontSize',9,'FontWeight','bold');
    xlabel('Iteration'); ylabel('Best Fitness'); grid on; box on;
    plotIdx=plotIdx+1;
  end
end
sgtitle('Figure 10: Convergence — GA vs PSO on CEC2005 F1 and F6 (5 sample runs)',...
    'FontSize',11,'FontWeight','bold');

%% FIGURE 11: Results Summary Bar Chart
figure('Name','Figure 11 - Results Summary','Position',[100 100 1000 420]);
experiments={'F1 D=2','F1 D=10','F6 D=2','F6 D=10'};
keys={'F1_Sphere_D2','F1_Sphere_D10','F6_Rosenbrock_D2','F6_Rosenbrock_D10'};
ga_means=zeros(4,1); pso_means=zeros(4,1);
ga_stds =zeros(4,1); pso_stds =zeros(4,1);

for i=1:4
    ga_means(i)=mean(results.(keys{i}).ga);
    pso_means(i)=mean(results.(keys{i}).pso);
    ga_stds(i) =std(results.(keys{i}).ga);
    pso_stds(i)=std(results.(keys{i}).pso);
end

x=1:4;
b=bar(x,[ga_means,pso_means],0.65);
b(1).FaceColor=[0.2 0.4 0.8];
b(2).FaceColor=[0.9 0.4 0.1];
hold on;
% Error bars
ngroups=4; nbars=2; groupwidth=min(0.8,nbars/(nbars+1.5));
for i=1:nbars
    xpos=x+(2*i-nbars-1)/2*(groupwidth/nbars);
    if i==1, errorbar(xpos,ga_means, ga_stds,'k.','LineWidth',1.5);
    else,     errorbar(xpos,pso_means,pso_stds,'k.','LineWidth',1.5); end
end
set(gca,'XTickLabel',experiments,'FontSize',11);
ylabel('Mean Best Fitness (15 runs)','FontWeight','bold','FontSize',11);
title('Figure 11: GA vs PSO Mean Performance on CEC2005 Benchmarks',...
    'FontSize',12,'FontWeight','bold');
legend('GA','PSO','Location','northwest'); grid on; box on;