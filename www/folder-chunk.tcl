# file-storage/www/folder-chunk.tcl

ad_page_contract {
    @author yon (yon@openforce.net)
    @creation-date Feb 22, 2002
    @cvs-id $Id$
} -query {
    {orderby:optional}
} -properties {
    folder_name:onevalue
    contents:multirow
    content_size_total:onevalue
}

if {![exists_and_not_null folder_id]} {
    ad_return_complaint 1 [_ file-storage.lt_bad_folder_id_folder_]
    ad_script_abort
}

set viewing_user_id [ad_conn user_id]

permission::require_permission -party_id $viewing_user_id -object_id $folder_id -privilege "read"

set admin_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "admin"]

set write_p $admin_p

if {!$write_p} {
    set write_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "write"]
}

set delete_p $admin_p

if {!$delete_p} {
    set delete_p [permission::permission_p -party_id $viewing_user_id -object_id $folder_id -privilege "delete"]
}

if {![exists_and_not_null n_past_days]} {
    set n_past_days 99999
}

if {![exists_and_not_null fs_url]} {
    set fs_url ""
}

set folder_name [lang::util::localize [fs::get_object_name -object_id  $folder_id]]

set content_size_total 0

if {![exists_and_not_null root_folder_id]} {
    set root_folder_id [fs::get_root_folder]
}

if {![string equal $root_folder_id $folder_id]} {
    set folder_path [db_exec_plsql get_folder_path {}]
} else {
    set folder_path ""
}

set actions [list]

# for now, invite users to upload, and then they will be asked to
# login if they are not.

lappend actions "\#file-storage.Upload_File\#" ${fs_url}file-add?[export_vars folder_id] "Upload a file in this folder" "Add Link" ${fs_url}simple-add?[export_vars folder_id] "Add a link to a web page" "\#file-storage.New_Folder\#" ${fs_url}folder-create?[export_vars {{parent_id $folder_id}}] "\#file-storage.Create_a_new_folder\#"


if {$delete_p} {
    lappend actions "Delete Folder" ${fs_url}folder-delete?[export_vars folder_id] "Delete folder"
}
if {$admin_p} {
    set return_url [ad_conn url]
    lappend actions "Rename Folder" "${fs_url}folder-edit?folder_id=$folder_id" "Change the name of this folder"
    lappend actions "Folder Permissions" "/permissions/one?[export_vars -override {{object_id $folder_id}} {return_url}]" "Change the permissions of this folder"
}

#set n_past_filter_values [list [list "Yesterday" 1] [list [_ file-storage.last_week] 7] [list [_ file-storage.last_month] 30]]

set elements [list icon \
		  [list label "" \
		       display_template {<a href="@contents.file_url@"><img src="@contents.icon@"  border=0 alt="#file-storage.@contents.type@#" /></a>}] \
		  name \
		  [list label [_ file-storage.Name] \
		       link_url_col file_url \
		       orderby_desc {fs_objects.name desc} \
		       orderby_asc {fs_objects.name asc}] \
		  content_size_pretty \
		  [list label [_ file-storage.Size] \
		       orderby_desc {content_size desc} \
		       orderby_asc {content_size asc}] \
		  type [list label [_ file-storage.Type] \
			    orderby_desc {type desc} \
			    orderby_asc {type asc}] \
		  last_modified_pretty \
		  [list label [_ file-storage.Last_Modified] \
		       orderby_desc {last_modified_ansi desc} \
		       orderby_asc {last_modified_ansi asc}] \
		  properties_link \
		  [list label "" \
		       link_url_col properties_url]
	      ]

template::list::create \
    -name contents \
    -multirow contents \
    -key object_id \
    -actions $actions \
    -filters {
	folder_id {hide_p 1}
    } \
    -elements $elements

set orderby [template::list::orderby_clause -orderby -name contents]

if {[string equal $orderby ""]} {
    set orderby " order by fs_objects.sort_key, fs_objects.name asc"
}

db_multirow -extend { icon last_modified_pretty content_size_pretty properties_link properties_url} contents select_folder_contents {} {
    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]

    set last_modified_pretty [lc_time_fmt $last_modified_ansi "%x %X"]
    set content_size_pretty [lc_numeric $content_size]
    if {[string equal $type "folder"]} {
	append content_size_pretty " [_ file-storage.items]"
    } else {
	append content_size_pretty " [_ file-storage.bytes]"
    }

    set file_upload_name [fs::remove_special_file_system_characters -string $file_upload_name]

    if { ![empty_string_p $content_size] } {
        incr content_size_total $content_size
    }

    set name [lang::util::localize $name]

    switch -- $type {
	folder {
	    set properties_link ""
	    set properties_url ""
	    set icon "/resources/file-storage/folder.gif"
	    set file_url "${fs_url}index?[export_vars {{folder_id $object_id}}]"
	}
	url {
	    set properties_link "properties"
	    set properties_url "${fs_url}simple?[export_vars object_id]"
	    set icon "/resources/url-button.gif"
	    set file_url ${fs_url}${url}
	}
	default {
	    set properties_link [_ file-storage.properties]
	    set properties_url "${fs_url}file?[export_vars {{file_id $object_id}}]"
	    set icon "/resources/file-storage/file.gif"
	    set file_url "${fs_url}view/${file_url}"
	}
    }
    

    # We need to encode the hashes in any i18n message keys (.LRN plays this trick on some of its folders).
    # If we don't, the hashes will cause the path to be chopped off (by ns_conn url) at the leftmost hash.
    regsub -all {#} $file_url {%23} file_url
}

ad_return_template
