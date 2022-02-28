#!/bin/bash

mydir="$(dirname $(realpath $0))"

# Optionally add parameter --no-ff to not automatically fast forward merge if possible
if [[ "$1" = "--no-ff" ]] ; then
    DO_FF=0
else
    DO_FF=1
fi

  CBLACK=$(tput setaf 0)
    CRED=$(tput setaf 1)
  CGREEN=$(tput setaf 2)
  CBROWN=$(tput setaf 3)
   CBLUE=$(tput setaf 4)
 CPURPLE=$(tput setaf 5)
   CCYAN=$(tput setaf 6)
  CLGRAY=$(tput setaf 7)
  CDGRAY=$(tput setaf 8)
   CLRED=$(tput setaf 9)
 CLGREEN=$(tput setaf 10)
 CYELLOW=$(tput setaf 11)
  CLBLUE=$(tput setaf 12)
CLPURPLE=$(tput setaf 13)
  CLCYAN=$(tput setaf 14)
  CWHITE=$(tput setaf 15)
      CR=$(tput sgr0)
   CBOLD=$(tput bold)

source "${mydir}/settings_repos_status.sh"

# Enumerate singly dirs
for dir in "${single_dirs[@]}" ; do
    if [[ -d "${dir}/.git" ]] ; then
        dirs+="${dir}
"
    fi
done

# Enumerate child dirs
for dir in "${subdirs[@]}" ; do
    if [[ -d "${dir}" ]] ; then
        for subdir in $(find "${dir}" -maxdepth 1 -type d) ; do
            if [[ -d "${subdir}/.git" ]] ; then
                dirs+="${subdir}
"
            fi
        done
    fi
done

current_dir="$(pwd)"

# Fetch all repos in parallel
set +m # Squelch job termination messages
for dir in $dirs ; do
    cd "${dir}"
    { git fetch --all --prune & } > /dev/null 2>&1 # Squelch job creation message
done

wait # Wait for all child processes to exit

# Print repo statuses
for dir in $dirs ; do
    cd "${dir}"
    branch="$(git branch | grep '^*' | cut -c 3-)"
    found=0
    for bb in "${base_branches[@]}" ; do
        if [[ "${branch}" == "${bb}" ]] ; then
            found=1
            break
        fi
    done
    if [[ ${found} = 1 ]] ; then
        status="$(git status --porcelain=v2 --branch)"
        ahead="$(echo "${status}" | grep '^# branch.ab' | sed -E 's/.*\+([0-9]+) -([0-9]+)/\1/g')"
        if [[ -n "${ahead}" ]] && (( ${ahead} > 0 )) ; then echo -e "${dir}: ${CGREEN}Commits ahead: ${ahead}${CR}" ; fi
        behind="$(echo "${status}" | grep '^# branch.ab' | sed -E 's/.*\+([0-9]+) -([0-9]+)/\2/g')"
        if [[ -n "${behind}" ]] && (( ${behind} > 0 )) ; then echo -e "${dir}: ${CRED}Commits behind: ${behind}${CR}" ; fi
        modified="$(echo "${status}" | grep -v -e '^?' -e '^#' | wc -l)"
        if [[ -n "${modified}" ]] && (( ${modified} > 0 )) ; then echo -e "${dir}: ${CCYAN}Modified files: ${modified}${CR}" ; fi
        untracked="$(echo "${status}" | grep '^?' | wc -l)"
        if [[ -n "${untracked}" ]] && (( ${untracked} > 0 )) ; then echo -e "${dir}: ${CPURPLE}Untracked files: ${untracked}${CR}" ; fi

        if [[ -z "${ahead}" ]] ||  [[ -z "${behind}" ]] || [[ -z "${modified}" ]] || [[ -z "${untracked}" ]] ; then
            echo -e "${dir}:${branch}:"
            echo -e "ahead=${ahead}\nbehind=${behind}\nmodified=${modified}\nuntracked=${untracked}"
        fi

        # Check for ff
        if [[ -n "${ahead}" ]] && [[ -n "${behind}" ]] && [[ -n "${modified}" ]] ; then
            if (( $DO_FF == 1 )) && (( $ahead == 0 )) && (( $behind > 0 )) && (( $modified == 0 )) ; then
                git merge --ff-only
            fi
        fi
    else
        echo -e "${dir}: checked out: ${branch}"
    fi
    # Check for unmerged commits
    unpushed="$(git log --branches --not --remotes --no-walk --decorate --oneline | grep -v HEAD | awk '{print $2}' | tr -d '[()]')"
    if [[ -n "${unpushed}" ]] ; then echo -e "${dir}: ${CRED}Unpushed branches:${CR}\n${unpushed}" ; fi
done
cd "${current_dir}"
