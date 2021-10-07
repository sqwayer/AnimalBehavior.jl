chn = sample(mdl1, sim.data, HMC(0.05, 10), MCMCThreads(), 1000, 2)
post = posterior(mdl1, chn, sim.data)

@test expectation(post).latent.α ≈ 0.5 atol=0.1
