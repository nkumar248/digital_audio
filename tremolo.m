% code written for digital audio class HS24, functions such as load_audio, save_audio, .. given 
% task: implement tremolo 

addpath('..')

infile = '';
outfile = '';
depth = 1; % 0 (no effect) to 1.0 (max amplitude modulation)
lfo_freq = 5; % 0.1 - 10 Hz
lfo_shape = 'sin'; % options: sin, tri, rect

% load input audio
[y,FS] = load_audio(infile);
input_audio_len = length(y);


% idea: 
% sample modulation wave (given shape and freq) at same sample rate as
% input sound, then multiply mod samples and sound samples element-wise
% while incorporating depth in some way

% sampling vector containing sampling instants
t = (0:input_audio_len-1) / FS;

% amplitude modulation wave at lfo_freq and sampled at instants in t
switch lfo_shape
    case 'sin'
        lfo = sin(2*pi*lfo_freq*t);
    case 'tri'
        lfo = sawtooth(2*pi*lfo_freq*t, 0.5); % Triangle wave (using "signal processing toolbox")
    case 'rect'
        lfo = sign(sin(2*pi*lfo_freq*t)); 
end


% determine how strong lfo modulation should be using depth param
% lfo oscillates between -1 and +1, after mult. with depth between -depth
% and +depth
% - depth = 0 -> lfo = 1 -> no modulation
% - depth = 1 -> 0 <= lfo <= 2 -> danger of clipping!
% - 0 <= depth <= 1 -> 0 < lfo < 2 -> danger of clipping!
lfo = 1 + depth * lfo;
lfo = lfo';


% debug
plot_signal(lfo, FS)


% multiply element-wise
y_trem = y .* lfo;

% handle clipping by normalization
max_amplitude = max(y_trem);
if max_amplitude > 1
    y_trem = y_trem / max_amplitude;
end


% play and visualize
play_audio(y_trem,FS,1);
plot_signal(y_trem,FS);

% save
save_audio(outfile,y_trem,FS)


