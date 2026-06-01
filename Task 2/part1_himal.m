% ========================================================
% PART 1: Mamdani Fuzzy Logic Controller for Smart Home
% Intelligent Assistive Care Environment
% Controls: Heater and Dimmer for a disabled resident
% ========================================================

clear; clc; close all;

%% ============================================================
%  FIGURE 1: Mamdani FLC Architecture Diagram
% ============================================================
figure('Name','Figure 1 - Mamdani FLC Architecture','Position',[100 100 900 350]);
hold on; axis off;
xlim([0 10]); ylim([0 5]);

% Boxes
rectangle('Position',[0.2 1.5 1.6 2],'Curvature',0.2,'FaceColor',[0.8 0.9 1],'EdgeColor','b','LineWidth',2);
rectangle('Position',[2.5 1.5 1.6 2],'Curvature',0.2,'FaceColor',[0.8 1 0.8],'EdgeColor',[0 0.6 0],'LineWidth',2);
rectangle('Position',[4.8 1.5 1.6 2],'Curvature',0.2,'FaceColor',[1 1 0.8],'EdgeColor',[0.8 0.6 0],'LineWidth',2);
rectangle('Position',[7.0 1.5 1.6 2],'Curvature',0.2,'FaceColor',[1 0.85 0.85],'EdgeColor','r','LineWidth',2);

% Labels inside boxes
text(1.0,2.8,'Fuzzifi-','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
text(1.0,2.4,'cation','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
text(3.3,2.8,'Rule','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
text(3.3,2.4,'Base','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
text(5.6,2.8,'Inference','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
text(5.6,2.4,'Engine','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
text(7.8,2.8,'Defuzzifi-','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');
text(7.8,2.4,'cation','HorizontalAlignment','center','FontSize',10,'FontWeight','bold');

% Arrows
annotation('arrow',[0.185 0.245],[0.5 0.5],'LineWidth',2,'Color','k');
annotation('arrow',[0.355 0.415],[0.5 0.5],'LineWidth',2,'Color','k');
annotation('arrow',[0.575 0.635],[0.5 0.5],'LineWidth',2,'Color','k');
annotation('arrow',[0.795 0.875],[0.5 0.5],'LineWidth',2,'Color','k');

% Input/Output labels
text(0.05,2.5,'Crisp','FontSize',9,'Color',[0.3 0.3 0.3]);
text(0.05,2.2,'Inputs','FontSize',9,'Color',[0.3 0.3 0.3]);
text(8.8,2.5,'Crisp','FontSize',9,'Color',[0.3 0.3 0.3]);
text(8.8,2.2,'Output','FontSize',9,'Color',[0.3 0.3 0.3]);

% Input labels at top
text(1.0,4.0,'Temperature','HorizontalAlignment','center','FontSize',8.5,'Color','b');
text(1.0,3.7,'Light Level','HorizontalAlignment','center','FontSize',8.5,'Color','b');
text(1.0,3.4,'Activity','HorizontalAlignment','center','FontSize',8.5,'Color','b');

% Output labels
text(7.8,4.0,'Heater (%)','HorizontalAlignment','center','FontSize',8.5,'Color','r');
text(7.8,3.7,'Dimmer (%)','HorizontalAlignment','center','FontSize',8.5,'Color','r');

title('Mamdani Fuzzy Logic Controller — Smart Home Architecture','FontSize',13,'FontWeight','bold');
text(5.6,0.8,'Mamdani Model: Rule outputs are fuzzy sets, aggregated and defuzzified using Centroid method',...
    'HorizontalAlignment','center','FontSize',8.5,'Color',[0.4 0.4 0.4],'FontAngle','italic');
%% ============================================================
%  HELPER FUNCTION: Triangular membership function
% ============================================================

function y = trimf_val(x, params)
    a=params(1); b=params(2); c=params(3);
    y = zeros(size(x));
    if a~=b
        idx=(x>=a)&(x<=b); y(idx)=(x(idx)-a)/(b-a);
    end
    if b~=c
        idx=(x>b)&(x<=c);  y(idx)=(c-x(idx))/(c-b);
    end
    y(x==b)=1;
end

%% ============================================================
%  FIGURE 2: Input Membership Functions
% ============================================================
figure('Name','Figure 2 - Input Membership Functions','Position',[100 100 1100 350]);

% Temperature
subplot(1,3,1);
x = 0:0.5:40;
plot(x, trimf_val(x,[0 0 18]),   'b-',  'LineWidth',2.5); hold on;
plot(x, trimf_val(x,[12 22 30]), 'g-',  'LineWidth',2.5);
plot(x, trimf_val(x,[25 40 40]), 'r-',  'LineWidth',2.5);
legend('Cold','Comfortable','Hot','Location','north');
title('Temperature (°C)','FontWeight','bold');
xlabel('Temperature (°C)'); ylabel('Membership Degree \mu');
ylim([0 1.15]); xlim([0 40]); grid on; box on;
set(gca,'FontSize',10);

% Light Level
subplot(1,3,2);
x = 0:1:100;
plot(x, trimf_val(x,[0 0 35]),    'b-', 'LineWidth',2.5); hold on;
plot(x, trimf_val(x,[25 50 75]),  'g-', 'LineWidth',2.5);
plot(x, trimf_val(x,[65 100 100]),'r-', 'LineWidth',2.5);
legend('Dark','Medium','Bright','Location','north');
title('Light Level (%)','FontWeight','bold');
xlabel('Light Level (%)'); ylabel('Membership Degree \mu');
ylim([0 1.15]); xlim([0 100]); grid on; box on;
set(gca,'FontSize',10);

% Activity
subplot(1,3,3);
x = 0:0.1:10;
plot(x, trimf_val(x,[0 0 4]),   'b-',  'LineWidth',2.5); hold on;
plot(x, trimf_val(x,[3 5 7]),   'g-',  'LineWidth',2.5);
plot(x, trimf_val(x,[6 10 10]), 'r-',  'LineWidth',2.5);
legend('Low','Medium','High','Location','north');
title('Activity Level','FontWeight','bold');
xlabel('Activity Level (0-10)'); ylabel('Membership Degree \mu');
ylim([0 1.15]); xlim([0 10]); grid on; box on;
set(gca,'FontSize',10);

sgtitle('Figure 2: Input Variable Membership Functions','FontSize',12,'FontWeight','bold');

%% ============================================================
%  FIGURE 3: Output Membership Functions
% ============================================================
figure('Name','Figure 3 - Output Membership Functions','Position',[100 100 1000 380]);
x = 0:1:100;

subplot(1,2,1);
plot(x, trimf_val(x,[0 0 25]),    'b-',  'LineWidth',2.5); hold on;
plot(x, trimf_val(x,[15 35 55]),  'c-',  'LineWidth',2.5);
plot(x, trimf_val(x,[45 60 75]),  'g-',  'LineWidth',2.5);
plot(x, trimf_val(x,[65 82 95]),  'm-',  'LineWidth',2.5);
plot(x, trimf_val(x,[85 100 100]),'r-',  'LineWidth',2.5);
legend('Off','Low','Medium','High','Full','Location','north');
title('Output: Heater Power (%)','FontWeight','bold');
xlabel('Heater Output (%)'); ylabel('Membership Degree \mu');
ylim([0 1.15]); xlim([0 100]); grid on; box on;
set(gca,'FontSize',10);

subplot(1,2,2);
plot(x, trimf_val(x,[0 0 20]),    'b-',  'LineWidth',2.5); hold on;
plot(x, trimf_val(x,[15 35 55]),  'c-',  'LineWidth',2.5);
plot(x, trimf_val(x,[50 65 80]),  'g-',  'LineWidth',2.5);
plot(x, trimf_val(x,[70 85 100]), 'r-',  'LineWidth',2.5);
legend('Off','Low','Medium','High','Location','north');
title('Output: Dimmer Level (%)','FontWeight','bold');
xlabel('Dimmer Output (%)'); ylabel('Membership Degree \mu');
ylim([0 1.15]); xlim([0 100]); grid on; box on;
set(gca,'FontSize',10);

sgtitle('Figure 3: Output Variable Membership Functions','FontSize',12,'FontWeight','bold');

%% ============================================================
%  FIGURE 4: Rule Activation — Scenario Example
%  Scenario: Cold night (T=8), Dark room (L=15), Active user (A=7)
% ============================================================
T=8; L=15; A=7;
output_range = 0:1:100;

% Fuzzify inputs
tc = trimf_val(T,[0 0 18]);
tco= trimf_val(T,[12 22 30]);
th = trimf_val(T,[25 40 40]);
ld = trimf_val(L,[0 0 35]);
lm = trimf_val(L,[25 50 75]);
lb2= trimf_val(L,[65 100 100]);
al = trimf_val(A,[0 0 4]);
am = trimf_val(A,[3 5 7]);
ah = trimf_val(A,[6 10 10]);

% Rule strengths
r1=tc; r2=th; r3=tco;
r4=min(tc,ah); r5=min(tc,al);
r6=min(th,ah); r7=min(tco,al);
r8=ld; r9=lb2; r10=lm;
r11=min(ld,ah); r12=min(ld,al);
r13=min(lm,al); r14=min(lb2,ah);

% Output MFs
h_off=trimf_val(output_range,[0 0 25]);
h_low=trimf_val(output_range,[15 35 55]);
h_med=trimf_val(output_range,[45 60 75]);
h_hi =trimf_val(output_range,[65 82 95]);
h_ful=trimf_val(output_range,[85 100 100]);
d_off=trimf_val(output_range,[0 0 20]);
d_low=trimf_val(output_range,[15 35 55]);
d_med=trimf_val(output_range,[50 65 80]);
d_hi =trimf_val(output_range,[70 85 100]);

% Aggregate
h_agg=max([min(r2,h_off);min(r6,h_off);min(r7,h_low);...
           min(r3,h_med);min(r4,h_hi);min(r1,h_ful);min(r5,h_ful)]);
d_agg=max([min(r9,d_off);min(r14,d_off);min(r12,d_low);...
           min(r13,d_low);min(r10,d_med);min(r8,d_hi);min(r11,d_hi)]);

% Defuzzify
h_out = sum(output_range.*h_agg)/sum(h_agg);
d_out = sum(output_range.*d_agg)/sum(d_agg);

figure('Name','Figure 4 - Rule Activation','Position',[100 100 1000 420]);
subplot(1,2,1);
area(output_range, h_agg,'FaceColor',[0.6 0.8 1],'EdgeColor','b','LineWidth',1.5);
hold on;
xline(h_out,'r--','LineWidth',2.5);
text(h_out+1, 0.5, sprintf('Centroid\n= %.1f%%',h_out),'Color','r','FontSize',10,'FontWeight','bold');
title(sprintf('Heater Aggregated Output\n(T=%d°C, L=%d%%, A=%d)',T,L,A),'FontWeight','bold');
xlabel('Heater Output (%)'); ylabel('Aggregated \mu');
ylim([0 1.1]); grid on; box on; set(gca,'FontSize',10);

subplot(1,2,2);
area(output_range, d_agg,'FaceColor',[0.6 1 0.7],'EdgeColor',[0 0.6 0],'LineWidth',1.5);
hold on;
xline(d_out,'r--','LineWidth',2.5);
text(d_out+1, 0.5, sprintf('Centroid\n= %.1f%%',d_out),'Color','r','FontSize',10,'FontWeight','bold');
title(sprintf('Dimmer Aggregated Output\n(T=%d°C, L=%d%%, A=%d)',T,L,A),'FontWeight','bold');
xlabel('Dimmer Output (%)'); ylabel('Aggregated \mu');
ylim([0 1.1]); grid on; box on; set(gca,'FontSize',10);

sgtitle('Figure 4: Rule Activation and Defuzzification — Operational Scenario','FontSize',12,'FontWeight','bold');

fprintf('\n=== Operational Scenario (T=%d, L=%d, A=%d) ===\n',T,L,A);
fprintf('Heater output : %.2f%%\n', h_out);
fprintf('Dimmer output : %.2f%%\n', d_out);

%% ============================================================
%  FIGURE 5: Control Surface — Temperature x Activity → Heater
% ============================================================
temp_v = 0:2:40;
act_v  = 0:0.5:10;
H_surf = zeros(length(temp_v), length(act_v));

for i=1:length(temp_v)
  for j=1:length(act_v)
    Tv=temp_v(i); Av=act_v(j); Lv=50;
    tc_=trimf_val(Tv,[0 0 18]); tco_=trimf_val(Tv,[12 22 30]); th_=trimf_val(Tv,[25 40 40]);
    al_=trimf_val(Av,[0 0 4]);  am_=trimf_val(Av,[3 5 7]);     ah_=trimf_val(Av,[6 10 10]);
    r1_=tc_; r3_=tco_; r4_=min(tc_,ah_); r5_=min(tc_,al_); r6_=min(th_,trimf_val(Av,[6 10 10])); r7_=min(tco_,al_); r2_=th_;
    ha=max([min(r2_,h_off);min(r6_,h_off);min(r7_,h_low);min(r3_,h_med);min(r4_,h_hi);min(r1_,h_ful);min(r5_,h_ful)]);
    if sum(ha)==0, H_surf(i,j)=50; else, H_surf(i,j)=sum(output_range.*ha)/sum(ha); end
  end
end

figure('Name','Figure 5 - Control Surface Heater','Position',[100 100 700 520]);
[T_mesh, A_mesh] = meshgrid(act_v, temp_v);
surf(T_mesh, A_mesh, H_surf,'EdgeColor','none');
colorbar; colormap(jet);
xlabel('Activity Level','FontSize',11,'FontWeight','bold');
ylabel('Temperature (°C)','FontSize',11,'FontWeight','bold');
zlabel('Heater Output (%)','FontSize',11,'FontWeight','bold');
title('Figure 5: Control Surface — Temperature × Activity → Heater','FontSize',12,'FontWeight','bold');
view(45,30); grid on; box on;

%% ============================================================
%  FIGURE 6: Control Surface — Light x Activity → Dimmer
% ============================================================
light_v = 0:5:100;
D_surf  = zeros(length(light_v), length(act_v));

for i=1:length(light_v)
  for j=1:length(act_v)
    Lv=light_v(i); Av=act_v(j);
    ld_=trimf_val(Lv,[0 0 35]); lm_=trimf_val(Lv,[25 50 75]); lb_=trimf_val(Lv,[65 100 100]);
    al_=trimf_val(Av,[0 0 4]);  ah_=trimf_val(Av,[6 10 10]);
    r8_=ld_; r9_=lb_; r10_=lm_; r11_=min(ld_,ah_); r12_=min(ld_,al_); r13_=min(lm_,al_); r14_=min(lb_,ah_);
    da=max([min(r9_,d_off);min(r14_,d_off);min(r12_,d_low);min(r13_,d_low);min(r10_,d_med);min(r8_,d_hi);min(r11_,d_hi)]);
    if sum(da)==0, D_surf(i,j)=50; else, D_surf(i,j)=sum(output_range.*da)/sum(da); end
  end
end

figure('Name','Figure 6 - Control Surface Dimmer','Position',[100 100 700 520]);
[L_mesh, A_mesh2] = meshgrid(act_v, light_v);
surf(L_mesh, A_mesh2, D_surf,'EdgeColor','none');
colorbar; colormap(parula);
xlabel('Activity Level','FontSize',11,'FontWeight','bold');
ylabel('Light Level (%)','FontSize',11,'FontWeight','bold');
zlabel('Dimmer Output (%)','FontSize',11,'FontWeight','bold');
title('Figure 6: Control Surface — Light Level × Activity → Dimmer','FontSize',12,'FontWeight','bold');
view(45,30); grid on; box on;

%% ============================================================
%  FIGURE 7: Scenario Testing — Bar Chart of Results
% ============================================================
scenario_names = {'Cold+Dark+Sleeping','Hot+Bright+Active','Comfortable+Medium','Cold+Dark+Active','Hot+Bright+Quiet'};
test_inputs = [5 10 1; 35 90 9; 22 55 5; 10 20 8; 30 80 3];
h_results = zeros(5,1);
d_results = zeros(5,1);

fprintf('\n=== FLC Scenario Testing Results ===\n');
fprintf('%-30s | Temp | Light | Act | Heater%% | Dimmer%%\n','Scenario');
fprintf('%s\n',repmat('-',1,75));

for i=1:5
    Tv=test_inputs(i,1); Lv=test_inputs(i,2); Av=test_inputs(i,3);
    tc_=trimf_val(Tv,[0 0 18]); tco_=trimf_val(Tv,[12 22 30]); th_=trimf_val(Tv,[25 40 40]);
    ld_=trimf_val(Lv,[0 0 35]); lm_=trimf_val(Lv,[25 50 75]); lb_=trimf_val(Lv,[65 100 100]);
    al_=trimf_val(Av,[0 0 4]);  am_=trimf_val(Av,[3 5 7]);     ah_=trimf_val(Av,[6 10 10]);
    r1_=tc_; r2_=th_; r3_=tco_;
    r4_=min(tc_,ah_); r5_=min(tc_,al_); r6_=min(th_,ah_); r7_=min(tco_,al_);
    r8_=ld_; r9_=lb_; r10_=lm_;
    r11_=min(ld_,ah_); r12_=min(ld_,al_); r13_=min(lm_,al_); r14_=min(lb_,ah_);
    ha=max([min(r2_,h_off);min(r6_,h_off);min(r7_,h_low);min(r3_,h_med);min(r4_,h_hi);min(r1_,h_ful);min(r5_,h_ful)]);
    da=max([min(r9_,d_off);min(r14_,d_off);min(r12_,d_low);min(r13_,d_low);min(r10_,d_med);min(r8_,d_hi);min(r11_,d_hi)]);
    if sum(ha)==0, h_results(i)=50; else, h_results(i)=sum(output_range.*ha)/sum(ha); end
    if sum(da)==0, d_results(i)=50; else, d_results(i)=sum(output_range.*da)/sum(da); end
    fprintf('%-30s | %4d | %5d | %3d | %7.1f | %7.1f\n',...
        scenario_names{i},Tv,Lv,Av,h_results(i),d_results(i));
end

figure('Name','Figure 7 - Scenario Results','Position',[100 100 950 420]);
x_pos = 1:5;
bar_data = [h_results, d_results];
b = bar(x_pos, bar_data, 0.65);
b(1).FaceColor = [0.85 0.33 0.1];
b(2).FaceColor = [0.47 0.67 0.19];
set(gca,'XTickLabel',scenario_names,'XTick',1:5,'FontSize',9);
xtickangle(15);
ylabel('Output (%)','FontSize',11,'FontWeight','bold');
title('Figure 7: FLC Output Across Five Operational Scenarios','FontSize',12,'FontWeight','bold');
legend('Heater Output','Dimmer Output','Location','northeast');
ylim([0 115]); grid on; box on;
for i=1:5
    text(i-0.18, h_results(i)+2, sprintf('%.0f',h_results(i)),'FontSize',8,'HorizontalAlignment','center');
    text(i+0.18, d_results(i)+2, sprintf('%.0f',d_results(i)),'FontSize',8,'HorizontalAlignment','center');
end