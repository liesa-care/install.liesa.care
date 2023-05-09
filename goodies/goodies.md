Disable play buttons
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist
launchctl load -w /System/Library/LaunchAgents/com.apple.rcd.plist