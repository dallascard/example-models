data {
  int<lower=0> nobs;            // Number of observed data
  int<lower=0> nmis;            // Number of missing data
  int<lower=0> nyear;           // Number of years
  int<lower=0> nsite;           // Number of sites
  int<lower=0> obs[nobs];       // Observed counts
  int<lower=0> obsyear[nobs];   // Years in observed data
  int<lower=0> obssite[nobs];   // Sites in observed data
  int<lower=0> misyear[nmis];   // Years in missing data
  int<lower=0> missite[nmis];   // Sites in missing data
  int<lower=0,upper=1> first[nyear, nsite];     // First-year observer?
  real year[nyear];             // Year
}

parameters {
  real mu;                      // Overall intercept
  real beta1;                   // Overall trend 
  real beta2;                   // First-year observer effect
  vector[nsite] alpha;          // Random site effects
  real<lower=0,upper=5> sd_alpha;
  vector[nyear] eps;            // Random year effects
  real<lower=0,upper=5> sd_eps;
}

transformed parameters {
  vector[nsite] log_lambda[nyear];

  for (i in 1:nyear)
    for (j in 1:nsite)
      log_lambda[i][j] <- mu + beta1 * year[i] + beta2 * first[i, j] +
                          alpha[j] + eps[i];
}

model {
  // Priors
  mu ~ normal(0, 10);
  beta1 ~ normal(0, 10);
  beta2 ~ normal(0, 10);

  alpha ~ normal(0, sd_alpha);
  sd_alpha ~ uniform(0, 5);

  eps ~ normal(0, sd_eps);
  sd_eps ~ uniform(0, 3);

  // Likelihood
  for (i in 1:nobs)
    obs[i] ~ poisson_log(log_lambda[obsyear[i]][obssite[i]]);
}

generated quantities {
  int<lower=0> mis[nmis];

  for (i in 1:nmis)
    mis[i] <- poisson_log_rng(log_lambda[misyear[i]][missite[i]]);
}
