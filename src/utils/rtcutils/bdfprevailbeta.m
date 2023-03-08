function flag = bdfprevailbeta(bdf_tau, bdf_k, beta)
if bdf_tau < 0
    error('wrong bdf_tau');
end
allX = beta(:, 1);
allbetaY = beta(:, 2);
allbdfY  = max(0, bdf_k * (allX - bdf_tau));
flag = all( round(allbdfY,5) >= round(allbetaY, 5)) && ...
    round(bdf_k,8) >= round(beta(end, 3),8);


end