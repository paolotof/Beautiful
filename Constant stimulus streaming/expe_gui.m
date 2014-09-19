function h = expe_gui(options)

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-02-24
% RuG / UMCG KNO, Groningen, NL
%--------------------------------------------------------------------------

close all hidden

h = struct();

fntsz = 40;


test_machine = is_test_machine();
if ~test_machine
    left=scrsz(1); bottom=scrsz(2); width=scrsz(3); height=scrsz(4);
else
    left = -1024; bottom=0; width=1024; height=768;
end
scrsz = [left, bottom, width, height];

h.background_color = [.4 .4 .4];
h.button_face_color = [0 0 .07]+.8;
h.button_border_color = h.button_face_color*.6;
h.button_press_color = .5*h.button_face_color+.5;
h.progress_bar_color = [.5 .8 .5];
h.main_text_color = [1 1 1]*.9;
h.button_right_color = h.progress_bar_color;
h.button_wrong_color = [1 .5 0];

h.f = figure('Visible', 'off', 'Position', scrsz, 'Menubar', 'none', 'Resize', 'off', 'Color', h.background_color);

% Progress bar
h.waitbar = axes('Units', 'pixel', 'Position', [width/2-300, height-50, 600, 25], 'Box', 'off', ...
    'XColor', 'w', 'YColor', 'w', 'XTick', [], 'YTick', []);
h.waitbar_legend = uicontrol('Style', 'text', 'Units', 'pixel', 'Position', [width/2-300, height-101, 600, 50], ...
    'HorizontalAlignment', 'center', 'FontSize', round(fntsz*.5), 'ForegroundColor', h.main_text_color, 'BackgroundColor', h.background_color);

% Response area
grid_sz = [2, 1]*500;
h.grid = axes('Units', 'pixel', 'Position', [width/2-grid_sz(1)/2, height/2-grid_sz(2)/2, grid_sz], ...
    'Box', 'off', 'Color', h.background_color);

n_rows = options.n_rows;
n_cols = options.n_cols;

% Margin
m = .1;

set(h.grid, 'XLim', [0, n_cols], 'YLim', [0, n_rows]);

for i=1:n_rows
    
    for j=1:n_cols
        
        h.patch(j+(i-1)*n_cols) = patch([0, 1, 1, 0]*(1-2*m)+m+j-1, [0, 0, 1, 1]*(1-2*m)+m+i-1, h.button_face_color, ...
            'FaceColor', h.button_face_color, 'EdgeColor', h.button_border_color, 'LineWidth', 2);
        hold on
        %plot([0, 1, 1, 0, 0]*(1-2*m)+m+j-1, [0, 0, 1, 1, 0]*(1-2*m)+m+i-1, '-', 'Color', h.button_border_color, 'LineWidth', 2);
        h.t(j+(i-1)*n_cols) = text(j-.5, i-.5, int2str(j+(i-1)*n_cols), 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', fntsz);    
    end
        
end
h.instruction = text(n_cols/2, n_rows/2, 'Instruction', 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', fntsz, 'Color', h.main_text_color);
hold off
set(h.grid, 'Xtick', [], 'YTick', [], 'Visible', 'off');


%-------- Actions
h.hide_buttons = @() set([h.patch(:), h.t(:)], 'Visible', 'off');
h.show_buttons = @() set([h.patch(:), h.t(:)], 'Visible', 'on');
h.hide_instruction = @() set(h.instruction, 'Visible', 'off');
h.show_instruction = @() set(h.instruction, 'Visible', 'on');
h.set_instruction = @(t) set(h.instruction, 'String', t);
h.set_progress = @(t, i, n) set_progress(h, t, i, n);
h.set_sylls = @(sylls) set_sylls(h, sylls);
h.patch_click = @CB_patch_click;
h.patch_pressed = false;

%-------- Events
set(h.f, 'WindowButtonUpFcn', {@CB_reset_colors, h});
for i=1:length(h.patch)
    set([h.patch(i), h.t(i)], 'ButtonDownFcn', {h.patch_click, i});
end

%-------- Initialize
h.hide_buttons();
set(h.f, 'UserData', h);
set(h.f, 'Visible', 'on');
drawnow();

%feedback_colors = {[.5, 0, 0], [0, .5, 0]};

%--------------------------------------------------------------------------
function CB_patch_click(src, event, i)

h = get(gcf, 'UserData');
set(h.patch(i), 'FaceColor', h.button_press_color);
h.last_clicked = i;
h.patch_pressed = true;
set(h.f, 'UserData', h);

%--------------------------------------------------------------------------
function CB_reset_colors(src, event, h)

h = get(gcf, 'UserData');
if h.patch_pressed % A patch has been clicked
    set(h.patch(:), 'FaceColor', h.button_face_color);
    uiresume();
    h.patch_pressed = false;
    set(h.f, 'UserData', h);
end

%--------------------------------------------------------------------------
function set_progress(h, t, i, n)

if n>0
    set(h.waitbar_legend, 'String', sprintf('%s: %d/%d', t, i, n));
    fill([0 1 1 0] * i/n, [0 0 1 1], h.progress_bar_color, 'Parent', h.waitbar, 'EdgeColor', 'none');
else
    set(h.waitbar_legend, 'String', t);
    fill([0 1 1 0] * 0, [0 0 1 1], h.progress_bar_color, 'Parent', h.waitbar, 'EdgeColor', 'none');
end
set(h.waitbar, 'XColor', 'w', 'YColor', 'w', 'XTick', [], 'YTick', [], 'Xlim', [0 1], 'YLim', [0 1]);

%--------------------------------------------------------------------------
function set_sylls(h, sylls)

for i=1:length(h.t(:))
    set(h.t(i), 'String', sylls{i});
end
