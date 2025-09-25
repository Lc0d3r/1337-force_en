#!/bin/bash

DIR="$HOME/force_en"
mkdir -p "$DIR"

# Write .force_en_while_locked.sh
echo '#!/bin/bash
# Kill ft_lock on login to prevent interference
pkill -x ft_lock >/dev/null 2>&1

# Restore normal layout first
setxkbmap -layout "us,ar" -option "grp:alt_shift_toggle"

while true; do
    # Check if ft_lock is running
    if pgrep -x ft_lock >/dev/null; then
        # Force English while locked
        setxkbmap us
        # Wait until ft_lock exits
        while pgrep -x ft_lock >/dev/null; do
            sleep 1
        done
        # After unlock → restore normal layouts
        setxkbmap -layout "us,ar" -option "grp:alt_shift_toggle"
    fi
    sleep 1
done' > "$DIR/.force_en_while_locked.sh"

# Write .loop_to_run_enforce.sh
echo '#!/bin/bash
# Restart force_en_while_locked.sh every minute to ensure it’s running

while true; do
    # Kill any old instance
    pkill -f force_en_while_locked.sh >/dev/null 2>&1
    # Start it fresh
    "$HOME/force_en/.force_en_while_locked.sh" &
    # Wait 60 seconds before next check
    sleep 60
done' > "$DIR/.loop_to_run_enforce.sh"

# Make them executable
chmod +x "$DIR/.force_en_while_locked.sh" "$DIR/.loop_to_run_enforce.sh"

# Add to .xprofile if not already there
if ! grep -q "$DIR/.loop_to_run_enforce.sh" "$HOME/.xprofile" 2>/dev/null; then
    echo "$DIR/.loop_to_run_enforce.sh &" >> "$HOME/.xprofile"
fi

echo "✅ Scripts installed in $DIR and autostart added to ~/.xprofile"

