# Template output module
# This is a template that you can use to implement your own tagging method.
# Please read MODIFY for more information.

# if you want your module to act as a "platform" then you'll have to set up variables as shown below
options+="custom - template (for testing)\n" # add yourself to the menu
# rescan=1 # set to 1 if you want to trigger a full rescan
# no_tags=1 # set to 1 to disable outputting tags from downloaded post info (i.e. you don't need tagging functionality)

# if you need to check for a dependency then use the built-in function dependency_check.
# it will check if your command fails and either notify the user or exit immediately if second argument is set to 'important'
# for example: dependency_check yourapp - notify and continue ($err will be set to 1)
# dependency_check yourapp important - notify and exit immediately

# if you're acting as a platform then your function must be named output_$yourplatform (as it was set in the menu and $options)
function output_custom {

	# you may implement a --delete option in your module. Only works if user chose to save the configuration
	if [[ "$1" == "--delete" ]]; then
		 echo "Removing $2"
	fi

	echo -e "librarydir=$librarydir\nfn=$fn\nsorteddir=$sorteddir"
}
