%% load eeg data
data_path = 'C:\Users\J-RC\Documents\Projects\HsMM-D2\D2_modulation\data\preprocessed\epoched2\';
data_files = dir(strcat(data_path,'*.set'));
for data_indx = 1:size(data_files,1)
    data_file = data_files(data_indx).name;
    cfg     = [];
    cfg.dataset      = strcat(data_path,data_file);
    cfg.continuous   = 'yes';
    data_eeg = ft_preprocessing(cfg);
    % convert elec positions in mm
    data_eeg.elec  = ft_convert_units(data_eeg.elec,'mm');
    elec = data_eeg.elec;

    %% prepare layout and plot
    cfg             = [];
    cfg.elec        = elec;
    layout          = ft_prepare_layout(cfg);

    %% scale the layout to fit the head outline
    lay         =layout;
    % Rotate in 90 degrees the electrodes
    tmp = lay.pos(1:end-2,1);
    lay.pos(1:end-2,1) = lay.pos(1:end-2,2);
    lay.pos(1:end-2,2) = tmp;
    %figure;
    %ft_plot_layout(lay)
    %% resegment the data into 1 sec chunks
    cfg             = [];
    cfg.length      = 1;
    dataseg         = ft_redefinetrial(cfg,data_eeg);

    %% Preprocess
    cfg               = [];
    cfg.dftfilter     = 'yes';
    cfg.reref         = 'yes';
    cfg.refchannel    = 'all';
    cfg.detrend       = 'yes';
    dataseg           = ft_preprocessing(cfg,dataseg);
    %% compute the power spectrum
    cfg              = [];
    cfg.output       = 'pow';
    cfg.method       = 'mtmfft';
    cfg.taper        = 'hanning';
    cfg.keeptrials   = 'no';
    datapow          = ft_freqanalysis(cfg, dataseg);

    %% plot the topography and the spectrum
    figure;
    cfg             = [];
    cfg.layout      = lay;
    cfg.xlim        = [9 11];
    cfg.colorbartext= 'Power';
    ft_topoplotER(cfg, datapow);
    colorbar;
    title('Alpha Power 9 - 11 Hz')
    saveas(gcf,['figures_D2/' data_file(1:8) '_Alphapow' '.png'])
            
    
    figure;
    cfg             = [];
    cfg.layout      = lay;
    cfg.xlim        = [4 8];
    cfg.colorbartext= 'Power';
    ft_topoplotER(cfg, datapow);
    colorbar;
    title('Theta Power 4 - 8 Hz')
    saveas(gcf,['figures_D2/' data_file(1:8) '_Thetapow' '.png'])
    
    figure;
    cfg             = [];
    cfg.layout      = lay;
    cfg.xlim        = [13 30];
    cfg.colorbartext= 'Power';
    ft_topoplotER(cfg, datapow);
    colorbar;
    title('Beta Power 13 - 30 Hz')
    saveas(gcf,['figures_D2/' data_file(1:8) '_Betapow' '.png'])
    

    figure;
    cfg             = [];
    cfg.channel     = {'OZ' 'O1','O2', 'PO4','POZ','PO3'};
    cfg.xlim        = [3 30];
    ft_singleplotER(cfg, datapow);
    xlabel('Frequency (Hz)')
    ylabel('Power (uV^2)')
    saveas(gcf,['figures_D2/' data_file(1:8) '_OccipitalSpectrum' '.png'])
    close all
    
end
