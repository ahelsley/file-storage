ad_library {
    TCL library for the file-storage system (v.4)

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 November 2000
    @version $Id$
}
 
ad_proc fs_get_root_folder {
    {-package_id ""}
} {
    Returns the root folder for the file storage system.
} {
    if [empty_string_p $package_id] {
	set package_id [ad_conn package_id]
    }

    return [fs::get_root_folder -package_id $package_id]
}

ad_proc fs_get_folder_name {
    folder_id
} {
    Returns the name of a folder. 
} {
    return [db_exec_plsql folder_name "
    begin
        :1 := file_storage.get_folder_name(:folder_id);
    end;"]
}

#
# Type-checking procs
#
# These might be cleaner if we were subtyping the CR object types
# We aren't checking if the objects are actually below the file-storage
# root, although we probably should.
#
# Note that we aren't using things like the content_folder.is_folder
# method because that will return 't' for things elsewhere in the
# content repository that have subclassed the default types.
#

ad_proc fs_folder_p {
    folder_id
} {
    Returns 1 if the folder_id corresponds to a folder in the file-storage
    system.  Returns 0 otherwise.
} {
    if {[string equal [db_string object_type "
    select object_type 
    from   acs_objects
    where  object_id = :folder_id" -default ""] "content_folder"]} {
	return 1
    } else {
	return 0
    }
}

ad_proc fs_file_p {
    file_id
} {
    Returns 1 if the file_id corresponds to a file in the file-storage
    system.  Returns 0 otherwise.
} {
    if {[string equal [db_string object_type "
    select object_type 
    from   acs_objects
    where  object_id = :file_id" -default ""] "content_item"]} {
	return 1
    } else {
	return 0
    }
}

ad_proc fs_version_p {
    version_id
} {
    Returns 1 if the version_id corresponds to a version in the file-storage
    system.  Returns 0 otherwise.
} {
    if {[string equal [db_string object_type "
    select object_type 
    from   acs_objects
    where  object_id = :version_id" -default ""] "file_storage_object"]} {
	return 1
    } else {
	return 0
    }
}

#
# Permission procs
#

ad_proc children_have_permission_p {
    {-user_id ""}
    item_id
    privilege
} {
    This procedure, given a content item and a privilege, checks to see if 
    there are any children of the item on which the user does not have that
    privilege.  It returns 0 if there is any child item on which the user
    does not have the privilege.  It returns 1 if the user has the
    privilege on every child item.
} {
    if [empty_string_p $user_id] {
	set user_id [ad_conn user_id]
    }

    # This only gets child folders and items

    set num_wo_perm [db_string child_perms "
    select count(*)
    from   cr_items
    where  item_id in (select item_id
                       from   cr_items
                       connect by prior item_id = parent_id
                       start with item_id = :item_id)
    and    acs_permission.permission_p(item_id,:user_id,:privilege) = 'f'"]

    # now check revisions

    db_foreach child_items {
	select item_id as child_item_id
	from   cr_items
	connect by prior item_id = parent_id
	start with item_id = :item_id
    } {
	incr num_wo_perm [db_string revision_perms "
	select count(*)
	from   cr_revisions
	where  item_id = :child_item_id
	and    acs_permission.permission_p(revision_id,:user_id,:privilege) = 'f'"]
    }

    if { $num_wo_perm > 0 } {
	return 0
    } else {
	return 1
    }

}


# 
# Display procs
#

ad_proc fs_context_bar_list {
    {-final ""}
    item_id
} {
    Constructs the list to be fed to ad_context_bar appropriate for
    item_id.  If -final is specified, that string will be the last 
    item in the context bar.  Otherwise, the name corresponding to 
    item_id will be used.
} {
    if [empty_string_p $final] {
	set start_id [db_string parent_id "
	select parent_id from cr_items where item_id = :item_id"]
	set final [db_exec_plsql title "begin
	    :1 := file_storage.get_title(:item_id);
	end;"]
    } else {
	set start_id $item_id
    }

    set context_bar [db_list_of_lists context_bar "
    select decode(
             file_storage.get_content_type(i.item_id),
             'content_folder',
             'index?folder_id=',
             'file?file_id='
           ) || i.item_id,
           file_storage.get_title(i.item_id)
    from   cr_items i
    where  item_id not in (
        select i2.item_id
        from   cr_items i2
        connect by prior i2.parent_id = i2.item_id
        start with i2.item_id = file_storage.get_root_folder([ad_conn package_id]))
    connect by prior i.parent_id = i.item_id
    start with item_id = :start_id
    order by level desc"]

    lappend context_bar $final

    return $context_bar
}

#
# Make sure we don't have page crashes due to unknown MIME types
#

ad_proc fs_maybe_create_new_mime_type {
    file_name
} {
    The content repository expects the MIME type to already be defined
    when you upload content.  We use this procedure to add a new type
    when we encounter something we haven't seen before.
} {

    set mime_type [ns_guesstype $file_name]
    set extension [string trimleft [file extension $file_name] "."]

    # don't know how to generate nice names like "JPEG Image"
    # have to leave it blank for now

    #set pretty_mime_type ???

    if { [db_string mime_type_exists {
        select count(*)
        from cr_mime_types
        where mime_type = :mime_type
    }] == 0 } {
        db_dml new_mime_type {
            insert into cr_mime_types
            (mime_type, file_extension)
            values
            (:mime_type, :extension)
        }
    }

    return $mime_type
}

namespace eval fs {

    ad_proc -public new_root_folder {
        {-package_id:required}
        {-pretty_name ""}
        {-description ""}
    } {
        Create a root folder for a package instance.

        @param package_id Package instance associated with this root folder

        @return folder_id of the new root folder
    } {
        return [db_exec_plsql new_root_folder {}]
    }

    ad_proc -public get_root_folder {
        {-package_id:required}
    } {
        Get the root folder of a package instance.

        @param package_id Package instance of the root folder to retrieve

        @return folder_id of the root folder retrieved
    } {
        return [db_exec_plsql get_root_folder {}]
    }

    ad_proc -public new_folder {
        {-name:required}
        {-pretty_name:required}
        {-parent_id:required}
        {-creation_user ""}
        {-creation_ip ""}
    } {
        Create a new folder.

        @param name Internal name of the folder, must be unique under a given
                    parent_id
        @param pretty_name What we show to users of the system
        @param parent_id Where we create this folder
        @param creation_user Who created this folder
        @param creation_ip What is the ip address of the creation_user

        @return folder_id of the newly created folder
    } {
        if {[empty_string_p $creation_user]} {
            set creation_user [ad_conn user_id]
        }

        if {[empty_string_p $creation_ip]} {
            set creation_ip [ns_conn peeraddr]
        }

        return [db_exec_plsql new_folder {}]
    }

    ad_proc -public get_folder {
        {-name:required}
        {-parent_id:required}
    } {
        Retrieve the folder_id of a folder given it's name and parent folder.

        @param name Internal name of the folder, must be unique under a given
                    parent_id
        @param parent_id The parent folder to look under

        @return folder_id of the folder, or null if no folder was found by that
                name
    } {
        return [db_string get_folder {} -default ""]
    }

    ad_proc -public get_folder_contents {
        {-folder_id:required}
        {-user_id ""}
    } {
        Retrieve the contents of the specified folder in the form of a list
        of ns_sets, one for each row returned. The keys for each row are as
        follows:

            file_id, name, live_revision, type,
            last_modified, content_size, sort_key

        @param folder_id The folder for which to retrieve contents
        @param user_id The viewer of the contents (to make sure they have
                       permission)
    } {
        if {[empty_string_p $user_id]} {
            set user_id [acs_magic_object "the_public"]
        }

        return [db_list_of_ns_sets get_folder_contents {}]
    }

}
