function convolCW = convolEnc(PHR, rsPSDU, cfg)
% As per Sec. 15.3.3.3 in IEEE Std 802.15.4™‐2020

if ~strcmp(cfg.Mode, 'HPRF') || cfg.ConstraintLength ~= 7
    encoding = true;
    rsPSDU = hrpRS(rsPSDU, encoding);
else
% no RS encoding when HPRF and constraint length = 7
    rsPSDU = rsPSDU;
end

% Two zeros for ConstraintLength = 3, six for length = 7
tailField = zeros(cfg.ConstraintLength-1, 1);

if cfg.ConvolutionalCoding
  if ~strcmp(cfg.Mode, 'HPRF') || cfg.ConstraintLength == 3
    % Table 15-1
    convolIn = [PHR; rsPSDU; tailField];
    
  else % CL = 7
    % Sec. 15.3.3.3 in 15.4z: "separately appending six zero bits to both the PHR and the PSDU"
    convolIn = [PHR; tailField; rsPSDU; tailField];
  end
else
  % Table 15-2 (Part 1)
  % No PSDU coding for some cases, as per Table 15-3
  % PHR is always convolutionally encoded
  convolIn = [PHR; tailField];
end

% Rate 1/2 coding:
if ~(strcmp(cfg.Mode, 'HPRF') && cfg.ConstraintLength == 7)
  % Constraint length 3, as in 15.3.3.3 in 15.4a 
  trellis3 = poly2trellis(3, [2 5]);
  convolCW = convenc(convolIn, trellis3);
else
  % Constraint length 7, as in 15.3.3.3 in 15.4z amendment
  trellis7 = poly2trellis(7, [133 171]);
  convolCW = convenc(convolIn, trellis7);  % repeat for codegen
end

if ~cfg.ConvolutionalCoding
  % Table 15-2 (Part 2)
  % Pass the PSDU further, without any convolutional coding
  convolCW = [convolCW; rsPSDU];
end