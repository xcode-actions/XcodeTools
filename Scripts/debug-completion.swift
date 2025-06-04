#!/usr/bin/env swift

import Foundation



let bold = "\u{1B}[1m"
let redBold = "\u{1B}[1;31m"
let reset = "\u{1B}[m"
let gray = "\u{1B}[0;38;5;245m"

print("""
\(redBold)All shells\(reset):
\(gray)# Not mandatory, but you’ll probably want that,\(reset)
\(gray)#  especially in bash while there is the bash completion script bug (it’s fixed now).\(reset)
\(gray)# See <https://github.com/apple/swift-argument-parser/pull/323>.\(reset)
XCT_DIR=`\\ls -d "$HOME/Library/Developer/Xcode/DerivedData/$(basename "$(realpath "$(pwd)")")"-*/"Build/Products/Debug"` \(gray)# We might be able to find better than this…\(reset)
test -d "$XCT_DIR" || { echo Invalid XCT_DIR; false; } \(gray)# Verify XCT_DIR is valid (detection above is not foolproof).\(reset)
export DYLD_FRAMEWORK_PATH="$XCT_DIR:$XCT_DIR/PackageFrameworks"
export DYLD_LIBRARY_PATH="$XCT_DIR"
export PATH="$XCT_DIR:$PATH"

\(redBold)If PS1 is too long (zsh)\(reset):
print -r "${(qqqq)PS1}" \(gray)# Get current PS1\(reset)
\(gray)# Change \(bold)%~\(gray) to \(bold)%2~\(gray) for instance\(reset)

\(redBold)zsh\(reset):
\(gray)# Once\(reset)
mkdir -p .build/completion_zsh
fpath=("$(pwd)/.build/completion_zsh" "${fpath[@]}")
\(gray)# After each xct build\(reset)
xct --generate-completion-script zsh >.build/completion_zsh/_xct && unfunction _xct && compinit -D
\(gray)# Or, for the root executable\(reset)
xct generate-meta-completion-script zsh >.build/completion_zsh/_xct && unfunction _xct && compinit -D

\(redBold)bash\(reset):
\(gray)# Once\(reset)
mkdir -p .build/completion_bash
\(gray)# After each xct build\(reset)
xct --generate-completion-script bash >.build/completion_bash/xct && . .build/completion_bash/xct
\(gray)# Or, for the root executable\(reset)
xct generate-meta-completion-script bash >.build/completion_bash/xct && . .build/completion_bash/xct
""")

/* When we’ll be able to build xct via the command line directly
print("""
\(redBold)All shells\(reset):
\(gray)# Not mandatory, but you’ll probably want that,\(reset)
\(gray)# especially in bash while there is the bash completion script bug\(reset)
\(gray)# See <https://github.com/apple/swift-argument-parser/pull/323>\(reset)
export PATH="$(pwd)/.build/debug:$PATH"

\(redBold)zsh\(reset):
\(gray)# Once\(reset)
mkdir -p .build/completion_zsh
fpath=("$(pwd)/.build/completion_zsh" "${fpath[@]}")
\(gray)# After each xct build\(reset)
swift run xct --generate-completion-script zsh >.build/completion_zsh/_xct && unfunction _xct && compinit -D

\(redBold)bash\(reset):
\(gray)# Once\(reset)
mkdir -p .build/completion_bash
\(gray)# After each xct build\(reset)
swift run xct --generate-completion-script bash >.build/completion_bash/xct && . .build/completion_bash/xct
""") */
