# Template output module
# This is a template that you can use to implement your own tagging method.
# Please read MODIFY for more information.

options+="custom - template (for testing)\n" # add yourself to the menu if required

# if you need to check for a dependency then use the built-in function dependency_check.
# it will check if your command fails and either notify the user or exit immediately if second argument is set to 'important'
# for example: dependency_check yourapp - notify and continue ($err will be set to 1)
# dependency_check yourapp important - notify and exit immediately

# if you're acting as a platform then your function must be named output_$yourplatform (as it was set in the menu and $options)
function output_custom {

	# you may implement a --delete option in your module. Only works if user chose to save the configuration
	if [[ "$1" == "--delete" ]]; then
		 echo "Removing $2"
		 exit
	fi

	# this will run before the configurator and right after user selects your module
	if [[ "$1" == "--selected" ]]; then
		 return 0
	fi

	# you may also implement an --init function to run something as soon as user chooses your module
	if [[ "$1" == "--init" ]]; then
		 #database=""./testprocessed.txt" # you can override the database file to store files processed by your module separately!
		 # no_tags=0 # set to 1 to disable all tagging functionality
		 # no_sort=0 # set to 1 to disable building a list of files to be processed
		 # echo "Initialized!"
		 return 0 # this is important, module will continue running through the code otherwise!
	fi

	echo -e "librarydir=$librarydir\nfn=$fn\nsorteddir=$sorteddir"
}
