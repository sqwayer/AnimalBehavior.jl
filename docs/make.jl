using Documenter
using AnimalBehavior

makedocs(
    sitename = "AnimalBehavior",
    format = Documenter.HTML(),
    modules = [AnimalBehavior]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
