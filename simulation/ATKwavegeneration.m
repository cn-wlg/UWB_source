function ATKwave = ATKwavegeneration(cfg_ATK,num,mode,firstzeros,ATKdelay,length_wave,power_ATKSHR,power_ATKSTS)
ATKSHR = createSHR(cfg_ATK);
ATKSTS = createATKSTS(cfg_ATK,num,mode);
ATKsymbols1 = ATKSHR;
ATKsymbols2 = ATKSTS;

ATKwave1 = butterworthFilter(ATKsymbols1, cfg_ATK.SamplesPerPulse);
ATKwave1 = ATKwave1/sqrt(powercal(ATKwave1))*sqrt(power_ATKSHR);

ATKwave2 = butterworthFilter(ATKsymbols2, cfg_ATK.SamplesPerPulse);
ATKwave2 = ATKwave2/sqrt(powercal(ATKwave2))*sqrt(power_ATKSTS);

%% Attack delay
ATKwave = [ATKwave1;ATKwave2];
ATKwave = [zeros(firstzeros+ATKdelay,1);ATKwave];
pad = zeros(length_wave-length(ATKwave),1);
ATKwave = [ATKwave;pad];

end
