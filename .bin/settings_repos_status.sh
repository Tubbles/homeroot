# List all known locations for git repositories that are of interrest
declare -a single_dirs=(
"${HOME}"
)

# We also search for first level subdirs in the following list
declare -a subdirs=(
"${HOME}/dev"
)

# The base branches that, if checked out, we do the actual sync of
declare -a base_branches=(
"main"
"master"
"develop"
)
