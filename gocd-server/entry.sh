#!/bin/sh

show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [COMMAND]...
Run GoCD with COMMAND and write the result to standard output.

    -h          display this help and exit
    -v          verbose mode. Can be used multiple times for increased
                verbosity.
EOF
}
# Break down GNU style long-options

# Reset all variables that might be set
verbose=0 # Variables to be evaluated as shell arithmetic should be initialized to a default or validated beforehand.

while :; do
    case $1 in
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
        -l|--log-level)
            verbose=$((verbose + 1)) # Each -v argument adds 1 to verbosity.
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1 $2" >&2
            if [ -n "$2" ]; then
                shift
            fi
            ;;    
        *)               # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

# if --file was provided, open it for writing, else duplicate stdout
exec 3>&1

# Rest of the program here.
# If there are input files (for example) that follow the options, they
# will remain in the "$@" positional parameters.

echo $#
