% code written for digital audio class HS24, functions such as load_audio, save_audio, .. given 
% task: implement vibrato 

addpath('..')

infile = '';
outfile = '';
depth = 0.04; % 0 (no effect) to 0.1 (max pitch modulation)
lfo_freq = 5; % 5 - 7 Hz for natural vibrato
lfo_shape = 'sin'; % options: sin, tri, rect
wet = 0.8; % 0.0 - 1.0 dry wet mix

% load input audio
[y,FS] = load_audio(infile);
input_audio_len = length(y);


% current idea: 
% read out samples at rate based on value of LFO

% LFO sampling vector containing sampling instants
t = (0:input_audio_len-1) / FS;

% pitch modulation wave at lfo_freq and sampled at instants in t
switch lfo_shape
    case 'sin'
        lfo = sin(2*pi*lfo_freq*t);
    case 'tri'
        lfo = sawtooth(2*pi*lfo_freq*t, 0.5); % Triangle wave (using "signal processing toolbox")
    case 'rect'
        lfo = sign(sin(2*pi*lfo_freq*t)); 
end

%plot_signal(lfo,FS)

% center rate is 1.0 (original playback rate), playback rate varies between 1-depth and 1+depth
playback_rate = 1 + depth * lfo;

cumulative_playback = cumsum(playback_rate) / FS;
sample_indices = cumulative_playback * FS;

% interpolate new indices
y_vibrato = interp1(1:length(y), y, sample_indices, 'linear', 'extrap');

dry = 1.0 - wet;
y_fin = dry*y' + wet*y_vibrato;

% handle clipping by normalization
max_amplitude = max(y_fin);
if max_amplitude > 1
    y_fin= y_fin / max_amplitude;
end


% play and visualize
play_audio(y_fin,FS,3);
plot_signal(y_fin,FS);

% save
save_audio(outfile,y_fin,FS)


