chn = sample(mdl1, sim.data, HMC(0.05, 10), 1000)
post = posterior(mdl1, chn, sim.data)

@test post.latent_avg.α ≈ 0.5 atol=0.1
