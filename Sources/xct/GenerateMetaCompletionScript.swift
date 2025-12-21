import Foundation

import ArgumentParser



/* This is the completion script for xct.
 * We call it meta because it’s able to call the sub-completion scripts for sub-commands properly. */
struct GenerateMetaCompletionScript : AsyncParsableCommand {
	
	static let configuration = CommandConfiguration(
		abstract: "Generate the completion script for xct. We use another algorithm than ArgumentParser’s, but I did not find a way to override the completion script from ArgumentParser, so I created a new command."
	)
	
	enum Shell : String, CaseIterable, ExpressibleByArgument {
		
		case zsh
		case bash
		
	}
	
	@Argument
	var shellName = Shell.zsh
	
	func run() throws {
		switch shellName {
			case .zsh:  print(Self.zshCompletion)
			case .bash: print(Self.bashCompletion)
		}
	}
	
	/* Resources:
	 * - Introduction to zsh completion script: <https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org>
	 *     Permalink: <https://github.com/zsh-users/zsh-completions/blob/6fbf5fc9a7033bc47d4c61b2d6b97fe0c74d9c45/zsh-completions-howto.org>
	 * - Details about _arguments: <https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Utility-Functions-1>
	 * - zsh-users completion style guide: <https://github.com/zsh-users/zsh/blob/master/Etc/completion-style-guide>
	 *     Permalink: <https://github.com/zsh-users/zsh/blob/ef60187efce77c0572daf419ca5ba57a28df3cad/Etc/completion-style-guide>
	 * - git’s completion: <file:///usr/share/zsh/5.8/functions/_git> */
	private static let zshCompletion = ##"""
		#compdef xct
		local context state state_descr line
		_xct_commandname="$words[1]"
		typeset -A opt_args
		
		_xct() {
			local curcontext=$curcontext
		
			integer ret=1
			local -a args
			# TODO: At _custom_completion call, we do not use exec-path; we should. Also -C? Less interesting that one, and probably more complicated to do.
			args+=(
				'(-h --help)'{-h,--help}'[Print help information.]'
				'--exec-path[Set the path to the core xct programs.]: :_directories'
				'-C[Change working directory before calling the tool.]: :_directories'
				'(-): :{_custom_completion "$_xct_commandname" ---completion  -- toolName $words}'
				'(-)*:: :->sub-command'
			)
			_arguments -C -w -s -S "${args[@]}" && return
		
			case $state in
				(sub-command)
					# TODO: Should we set cwd for -C, and, to a less extent, should we deal with exec-path?
					curcontext=${curcontext%:*:*}:xct-$words[1]:
					_call_function ret _xct-$words[1]
					;;
			esac
		
			return ret
		}
		
		_custom_completion() {
			local completions=("${(@f)$($*)}")
			_describe '' completions
		}
		
		_xct
		
		# Below is git’s completion script (w/ git renamed to xct).
		# Used as an inspiration.
		# Can be used again if we want to implement aliases someday for instance.
		
		#_xct() {
		#	if (( CURRENT > 2 )); then
		#		local -a aliases
		#		local -A xct_aliases
		#		local a k v
		#		local endopt='!(-)--end-of-options'
		#		aliases=(${(0)"$(_call_program aliases xct config -z --get-regexp '\^alias\.')"})
		#		for a in ${aliases}; do
		#				k="${${a/$'\n'*}/alias.}"
		#				v="${a#*$'\n'}"
		#				xct_aliases[$k]="$v"
		#		done
		#
		#		if (( $+xct_aliases[$words[2]] && !$+commands[xct-$words[2]] && !$+functions[_xct-$words[2]] )); then
		#			local -a tmpwords expalias
		#			expalias=(${(z)xct_aliases[$words[2]]})
		#			tmpwords=(${words[1]} ${expalias})
		#			if [[ -n "${words[3,-1]}" ]] ; then
		#				tmpwords+=(${words[3,-1]})
		#			fi
		#			[[ -n ${words[$CURRENT]} ]] || tmpwords+=('')
		#			(( CURRENT += ${#expalias} - 1 ))
		#			words=("${tmpwords[@]}")
		#			unset tmpwords expalias
		#		fi
		#
		#		unset xct_aliases aliases
		#	fi
		#
		#	integer ret=1
		#
		#	if [[ $service == xct ]]; then
		#		local curcontext=$curcontext state line
		#		declare -A opt_args
		#
		#		_arguments -C -w -s -S \
		#			'(-h --help)'{-h,--help}'[Print help information.]' \
		#			'--exec-path[Set the path to the core xct programs.]: :_directories' \
		#			'-C[Change working directory before calling the tool.]: :_directories' \
		#			'(-): :{_custom_completion "$_xct_commandname" ---completion  -- toolName $words}' \
		#			'(-)*:: :->sub-command' && return
		#
		#		case $state in
		#			(command)
		#				_xct_commands && ret=0
		#				;;
		#			(sub-command)
		#				curcontext=${curcontext%:*:*}:xct-$words[1]:
		#				(( $+opt_args[--xct-dir] )) && local -x xct_DIR=$opt_args[--xct-dir]
		#				if ! _call_function ret _xct-$words[1]; then
		#					if [[ $words[1] = \!* ]]; then
		#						words[1]=${words[1]##\!}
		#						_normal && ret=0
		#					elif zstyle -T :completion:$curcontext: use-fallback; then
		#						_default && ret=0
		#					else
		#						_message "unknown sub-command: $words[1]"
		#					fi
		#				fi
		#				;;
		#			(configuration)
		#				if compset -P 1 '*='; then
		#					__xct_config_value && ret=0
		#				else
		#					if compset -S '=*'; then
		#						__xct_config_option && ret=0 # don't move cursor if we completed just the "foo." in "foo.bar.baz=value"
		#						compstate[to_end]=''
		#					else
		#						__xct_config_option -S '=' && ret=0
		#					fi
		#				fi
		#				;;
		#		esac
		#	else
		#		_call_function ret _$service
		#	fi
		#
		#	return ret
		#}
		#
		# Load any _xct-* definitions so that they may be completed as commands.
		#declare -gUa _xct_external_commands
		#_xct_external_commands=()
		#
		#local file input
		#for file in ${^fpath}/_xct-*~(*~|*.zwc)(-.N); do
		#	local name=${${file:t}#_xct-}
		#	if (( $+_xct_external_commands[$name] )); then
		#		continue
		#	fi
		#
		#	local desc=
		#	integer i=1
		#	while read input; do
		#		if (( i == 2 )); then
		#			if [[ $input == '#description '* ]]; then
		#				desc=:${input#\#description }
		#			fi
		#			break
		#		fi
		#		(( i++ ))
		#	done < $file
		#
		#	_xct_external_commands+=$name$desc
		#done
		"""##
	
	/* Resources:
	 * - Introduction to bash completion: <https://www.linuxjournal.com/content/more-using-bash-complete-command>
	 * - git’s completion: <https://github.com/git/git/blob/master/contrib/completion/git-completion.bash>
	 *     Permalink: <https://github.com/git/git/blob/715d08a9e51251ad8290b181b6ac3b9e1f9719d7/contrib/completion/git-completion.bash> */
	private static let bashCompletion = """
		#!/bin/bash
		
		\(bashCompletionUtils)
		
		_xct() {
			# These are generated by the wrapper generated by ___xct_complete
			#echo cur $cur
			#echo words $words
			#echo cword $cword
			#echo prev $prev
			
			local i c=1 command __xct_exec_path
			local __xct_C_args C_args_count=0
			local __xct_cmd_idx
			
			while [ $c -lt $cword ]; do
				i="${words[c]}"
				case "$i" in
				--exec-path=*)
					__xct_exec_path="${i#--git-dir=}"
					;;
				--exec-path)
					((c++))
					__xct_exec_path="${words[c]}"
					;;
				-C)
					__xct_C_args[C_args_count++]=-C
					((c++))
					__xct_C_args[C_args_count++]="${words[c]}"
					;;
				-*)
					;;
				*)
					command="$i"
					__xct_cmd_idx="$c"
					break
					;;
				esac
				((c++))
			done
			
			if [ -z "${command-}" ]; then
				case "$prev" in
				-C|--exec-path)
					COMPREPLY=( $(compgen -d -- "$cur") )
					return
					;;
				esac
				local opts_one_dash="-C -h"
				local opts_two_dashes="--exec-path --help"
				case "$cur" in
				--*)
					COMPREPLY=( $(compgen -W "$opts_two_dashes" -- "$cur") )
					;;
				-*)
					COMPREPLY=( $(compgen -W "$opts_two_dashes $opts_one_dash" -- "$cur") )
					;;
				*)
					# TODO: We do not use exec-path here; we should. Also -C? Less interesting that one, and probably more complicated to do.
					local tool_names="$("${COMP_WORDS[0]}" ---completion  -- toolName "${COMP_WORDS[@]}")"
					COMPREPLY=( $(compgen -W "$tool_names $opts_two_dashes $opts_one_dash" -- "$cur") )
					;;
				esac
				return
			fi
			
			# TODO: Should we set cwd for -C, and, to a less extent, should we deal with exec-path?
			__xct_complete_command "$command" && return
		}
		___xct_complete xct _xct
		"""
	
	/* All of this is (adapted) from the git bash completion script. */
	private static let bashCompletionUtils = """
		__xct_have_func () {
			declare -f -- "$1" >/dev/null 2>&1
		}
		
		__xct_complete_command() {
			local command="$1"
			# TODO: I’m not sure this substitution is actually true with the completion scripts generated by swift argument parser
			local completion_func="_xct-${command//-/_}"
			if ! __xct_have_func $completion_func && __xct_have_func _completion_loader
			then
				_completion_loader "xct-$command"
			fi
			if __xct_have_func $completion_func
			then
				$completion_func
				return 0
			else
				return 1
			fi
		}
		
		# This function can be used to access a tokenized list of words on the command line:
		#
		#	__xct_reassemble_comp_words_by_ref '=:'
		#	if test "${words_[cword_-1]}" = -w
		#	then
		#		...
		#	fi
		#
		# The argument should be a collection of characters from the list of word completion separators (COMP_WORDBREAKS) to treat as ordinary characters.
		#
		# This is roughly equivalent to going back in time and setting COMP_WORDBREAKS to exclude those characters.
		# The intent is to make option types like --date=<type> and <rev>:<path> easy to recognize by treating each shell word as a single token.
		#
		# It is best not to set COMP_WORDBREAKS directly because the value is shared with other completion scripts.
		# By the time the completion function gets called, COMP_WORDS has already been populated so local changes to COMP_WORDBREAKS have no effect.
		#
		# Output: words_, cword_, cur_.
		__xct_reassemble_comp_words_by_ref() {
			local exclude i j first
			# Which word separators to exclude?
			exclude="${1//[^$COMP_WORDBREAKS]}"
			cword_=$COMP_CWORD
			if [ -z "$exclude" ]; then
				words_=("${COMP_WORDS[@]}")
				return
			fi
			# List of word completion separators has shrunk;
			# re-assemble words to complete.
			for ((i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++)); do
				# Append each nonempty word consisting of just word separator characters to the current word.
				first=t
				while
					[ $i -gt 0 ] &&
					[ -n "${COMP_WORDS[$i]}" ] &&
					# word consists of excluded word separators
					[ "${COMP_WORDS[$i]//[^$exclude]}" = "${COMP_WORDS[$i]}" ]
				do
					# Attach to the previous token,
					# unless the previous token is the command name.
					if [ $j -ge 2 ] && [ -n "$first" ]; then
						((j--))
					fi
					first=
					words_[$j]=${words_[j]}${COMP_WORDS[i]}
					if [ $i = $COMP_CWORD ]; then
						cword_=$j
					fi
					if (($i < ${#COMP_WORDS[@]} - 1)); then
						((i++))
					else
						# Done.
						return
					fi
				done
				words_[$j]=${words_[j]}${COMP_WORDS[i]}
				if [ $i = $COMP_CWORD ]; then
					cword_=$j
				fi
			done
		}
		
		__xct_get_comp_words_by_ref() {
			local exclude cur_ words_ cword_
			if [ "$1" = "-n" ]; then
				exclude=$2
				shift 2
			fi
			__xct_reassemble_comp_words_by_ref "$exclude"
			cur_=${words_[cword_]}
			while [ $# -gt 0 ]; do
				case "$1" in
				cur)
					cur=$cur_
					;;
				prev)
					prev=${words_[$cword_-1]}
					;;
				words)
					words=("${words_[@]}")
					;;
				cword)
					cword=$cword_
					;;
				esac
				shift
			done
		}
		
		__xct_func_wrap() {
			local cur words cword prev
			local __xct_cmd_idx=0
			__xct_get_comp_words_by_ref -n =: cur words cword prev
			$1
		}
		
		___xct_complete() {
			local wrapper="__xct_wrap${2}"
			eval "$wrapper() { __xct_func_wrap $2; }"
			complete -F $wrapper $1
		}
		"""
	
}
