ad_page_contract {
    script to copy a file into a new folder

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 14 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    parent_id:integer,notnull
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "The specified file is not valid."
	}
    }

    valid_folder -requires {parent_id} {
	if ![fs_folder_p $parent_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }
}

# check for read permission on the file and write permission on the
# target folder

ad_require_permission $file_id read
ad_require_permission $parent_id write

set user_id [ad_conn user_id]
set ip_address [ad_conn peeraddr]

# Question - do we copy revisions or not?
# Current Answer - we copy the live revision only

db_transaction {

    db_exec_plsql file_copy "
    begin
        file_storage.copy_file(
            item_id => :file_id
            target_folder_id => :parent_id,
            creation_user => :user_id,
            creation_ip => :ip_address
            );
    end;"

} on_error {

    ad_return_complaint 1 "The <a href=\"index?folder_id=$parent_id\">folder</a> you selected already contains a file with the same name. " 

#    <pre>$errmsg</pre>

    ad_script_abort
}

ad_returnredirect "?folder_id=$parent_id"
