     always_comb begin
       sat_sum <= (sum_accum > SAT_MAX) ? SAT_MAX :
                  (sum_accum < SAT_MIN) ? SAT_MIN :
                  sum_accum;
     end
     