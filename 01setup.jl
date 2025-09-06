using Pkg; using Dates; HOSTNAME = gethostname(); USERNAME = Sys.iswindows() ? ENV["USERNAME"] : ENV["USER"]
JAHR_NOW = year(now()); VERSION_STR = string(VERSION); REPO_DIR = @__DIR__ 
ENV_DIR = joinpath(REPO_DIR, "envs", "$JAHR_NOW-$VERSION_STR-$HOSTNAME-3"); Pkg.activate(ENV_DIR)
pkgs = split("Colors, OrderedCollections, ColorSchemes, CSV, DataFrames, XLSX, Distributions, CairoMakie, GLMakie, Printf, StatsBase, Dates, GLM, Random, LaTeXStrings, LinearAlgebra, RCall, Optim, DataFramesMeta, SparseArrays",", ")
pkgs .|> x -> Pkg.add(x) 
foreach(p -> (eval(Meta.parse("using $p")); println("✅ $p")), pkgs)