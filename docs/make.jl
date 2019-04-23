using Documenter, DocStringExtensions
using Beauty

makedocs(
    sitename="quantum-factory.de",
    format = Documenter.HTML(prettyurls = false),
    modules = [Beauty],
    repo = string(
        "https://bitbucket.org/quantumfactory/beauty.jl",
        "/src/{commit}{path}#lines-{line}"
    )
)
