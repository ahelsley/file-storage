ad_page_contract {
    form to create a new folder

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 7 Nov 2000
    @cvs-id $Id$
} {
    parent_id:integer,notnull
} -validate {
    valid_folder -requires {parent_id:integer} {
	if ![fs_folder_p $parent_id] {
	    ad_complain "[_ file-storage.lt_The_specified_parent_]"
	}
    }
} -properties {
    parent_id:onevalue
    context:onevalue
}

# check that they have write permission on the parent folder

ad_require_permission $parent_id write

# set templating datasources

set context [fs_context_bar_list -final "[_ file-storage.Create_New_Folder]" $parent_id]

ad_return_template

