ad_page_contract {
    add the new version into the system.

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 8 Nov 2000
    @cvs-id $Id$
} {
    file_id:integer,notnull
    upload_file:trim,notnull
    upload_file.tmpfile:tmpfile
    title:notnull
    description:trim
} -validate {
    valid_file -requires {file_id} {
	if ![fs_file_p $file_id] {
	    ad_complain "The specified file is not valid."
	}
    }

    max_size -requires {upload_file} {
	set n_bytes [file size ${upload_file.tmpfile}]
	set max_bytes [ad_parameter "MaximumFileSize"]
	if { $n_bytes > $max_bytes } {
	    ad_complain "Your file is larger than the maximum file size allowed on this system ([util_commify_number $max_bytes] bytes)"
	}
    }
}


# Check for write permission on the file
ad_require_permission $file_id write

# Get the user_id
set user_id [ad_conn user_id]

# Get the filename part of the upload file
if ![regexp {[^//\\]+$} $upload_file filename] {
    # no match
    set filename $upload_file
}

# Get the ip
set creation_ip [ad_conn peeraddr]

# The content repository is kinda stupid about mime types,
# so we have to check if we know about this one and possibly 
# add it.
set mime_type [fs_maybe_create_new_mime_type $upload_file]

# Get the storage type
set indb_p [ad_parameter "StoreFilesInDatabaseP" -package_id [ad_conn package_id]]

db_transaction {

    # create the new version
    set version_id [db_exec_plsql new_version "
	begin
	   :1 := file_storage__create_file (
                  name => :filename,
                  parent_id => :folder_id,
                  context_id => :folder_id,
                  creation_user => :user_id,
                  creation_ip => :creation_ip,
                  item_subtype => 'file_storage_item' -- needed by site-wide search
                  );
        end;"]


    if {$indb_p} {

	db_dml lob_content "
	update cr_revisions
	set    content = empty_blob()
	where  revision_id = :version_id
	returning content into :1" -blob_files [list ${upload_file.tmpfile}]


	# Unfortunately, we can only calculate the file size after the lob is uploaded 
	db_dml lob_size "
	update cr_revisions
	set    content_length = lob_length(lob)
	where  revision_id = :version_id"

    } else {

	set tmp_filename [cr_create_content_file $file_id $version_id ${upload_file.tmpfile}]
	set tmp_size [cr_file_size $tmp_filename]

	db_dml fs_content_size "
	update cr_revisions
	set filename = '$tmp_filename',
            content_length = $tmp_size
	where  revision_id = :version_id"

    }


}

ad_returnredirect "file?file_id=$file_id"