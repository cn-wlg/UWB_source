function systematicBits = convdec(cw, constraintLength)

  tbDepth = 5*(constraintLength-1);
  if constraintLength == 3
    systematicBits = viterbidec(cw);
  else
    % Constraint length 7, as in 15.3.3.3 in 15.4z amendment
    trellis = poly2trellis(7, [133 171]);
    if size(cw, 1)/2 < tbDepth % PHR
      cw = [cw; zeros(10, 1)]; 
    end
  systematicBits = vitdec(cw, trellis, tbDepth, 'trunc', 'hard');
  end
end